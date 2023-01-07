//
//  AddFavouriteMovieUseCaseTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 03/01/2023.
//

import XCTest
import MoviesFramework

final class AddFavouriteMovieUseCaseTests: XCTestCase {
    
    func test_init_doesnotMessageStore() {
        let (_,store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_addFavourite_requestsExistingDataRetrieval() {
        let (sut,store) = makeSUT()
        let items = uniqueMovieItems()
        sut.addFavourite(items.model) { _ in }
        XCTAssertEqual(store.receivedMessages, [.retrieveFavourite])
    }
    
    func test_addFavourite_deliversErrorOnExistingDataRetrievalFailure() {
        let (sut,store) = makeSUT()
        let retrievalError = anyNSError()
        expect(sut, toCompleteWithError: retrievalError, when: {
            store.completeFavouriteRetrival(with: retrievalError)
        })
    }
    
    func test_addFavourite_deliversInsertionErrorIfItemAlreadyExists() {
        let (sut,store) = makeSUT()
        let dataAlreadyExistsError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "This movie already existis in favourites"])
        let existingItem = uniqueMovieItems()
        expect(sut, toCompleteWithError: dataAlreadyExistsError, when: {
            store.completeFavouriteRetrival(with: [existingItem.dto])
        }, item: existingItem.model)
    }
    
    func test_addFavourite_requestInsertionOnEmptyExistingData() {
        let (sut,store) = makeSUT()
        let item = uniqueMovieItems()
        sut.addFavourite(item.model) { _ in}
        store.completeFavouriteRetrival(with: [])
        XCTAssertEqual(store.receivedMessages, [.retrieveFavourite, .insertFavourite(item.dto)])
    }
    
    func test_addFavourite_requestInsertionOnNonEmptyExistingDataButItemNotAddedAlready() {
        let (sut,store) = makeSUT()
        let oldItem1 = uniqueMovieItems()
        let oldItem2 = uniqueMovieItems()
        let newitem = uniqueMovieItems()
        
        sut.addFavourite(newitem.model) { _ in}
        
        store.completeFavouriteRetrival(with: [oldItem1.dto, oldItem2.dto])
        
        XCTAssertEqual(store.receivedMessages, [.retrieveFavourite, .insertFavourite(newitem.dto)])
    }
    
    
    func test_addFavourite_deliversErrorOnInsertionError() {
        let (sut,store) = makeSUT()
        
        let insertionError = anyNSError()
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeFavouriteRetrival(with: [])
            store.completeFavouriteInsertion(with: insertionError)
        })
    }
    
    
    func test_addFavourite_succeedsOnSuccessfulInsertion() {
        let (sut,store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeFavouriteRetrival(with: [])
            store.completeFavouriteInsertionSuccessfully()
        })
    }
    
    
    func test_addFavourite_doesNotRequestInsertionAfterSUTInstanceHasBeenDeallocated() {
        let store = FavouriteMoviesStoreSpy()
        var sut:AddFavouriteMovieUseCaseHandler? = AddFavouriteMovieUseCaseHandler(store: store)
        
        var receivedResults = [AddFavouriteMovieUseCaseHandler.addFavouriteResult]()
        sut?.addFavourite(uniqueMovieItem()) {
            receivedResults.append($0)
        }
        sut = nil
        store.completeFavouriteRetrival(with: [])
        XCTAssertEqual(store.receivedMessages, [.retrieveFavourite])
    }
    
    
    func test_addFavourite_doesNotDeliverInsertionResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FavouriteMoviesStoreSpy()
        var sut:AddFavouriteMovieUseCaseHandler? = AddFavouriteMovieUseCaseHandler(store: store)
        
        var receivedResults:[AddFavouriteMovieUseCaseHandler.addFavouriteResult]?
        sut?.addFavourite(uniqueMovieItem()) {
            receivedResults?.append($0)
        }
        store.completeFavouriteRetrival(with: [])
        sut = nil
        store.completeFavouriteInsertion(with: anyNSError())
        XCTAssertNil(receivedResults)
    }
    
    
    // MARK: - Helper
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:AddFavouriteMovieUseCase, store:FavouriteMoviesStoreSpy) {
        let store = FavouriteMoviesStoreSpy()
        let sut = AddFavouriteMovieUseCaseHandler(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut,store)
    }
    
    private func expect(_ sut: AddFavouriteMovieUseCase, toCompleteWithError expectedError:NSError?, when action:() -> Void, item:DomainMovie = uniqueMovieItem(), file: StaticString = #filePath, line: UInt = #line) {
        
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for completion")
        sut.addFavourite(item) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
}
