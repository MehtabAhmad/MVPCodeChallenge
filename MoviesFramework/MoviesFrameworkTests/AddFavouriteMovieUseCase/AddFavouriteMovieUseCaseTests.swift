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
    
    func test_addFavourite_requestsMovieInsertion() {
        let (sut,store) = makeSUT()
        let items = uniqueMovieItems()
        sut.addFavourite(items.model) { _ in }
        XCTAssertEqual(store.receivedMessages, [.insert(items.dto)])
    }
    
    func test_addFavourite_deliversErrorOnInsertionError() {
        let (sut,store) = makeSUT()
        
        let insertionError = anyNSError()
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeInsertion(with: insertionError)
        })
  
    }
    
    func test_addFavourite_succeedsOnSuccessfulInsertion() {
        let (sut,store) = makeSUT()
       
        expect(sut, toCompleteWithError: nil, when: {
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_addFavourite_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = MovieStoreSpy()
        var sut:AddFavouriteMovieUseCaseHandler? = AddFavouriteMovieUseCaseHandler(store: store)
        
        var receivedResults = [AddFavouriteMovieUseCaseHandler.addFavouriteResult]()
        sut?.addFavourite(uniqueMovieItem()) {
            receivedResults.append($0)
        }
        
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    
    // MARK: - Helper
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:AddFavouriteMovieUseCase, store:MovieStoreSpy) {
        let store = MovieStoreSpy()
        let sut = AddFavouriteMovieUseCaseHandler(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut,store)
    }
    
    private func expect(_ sut: AddFavouriteMovieUseCase, toCompleteWithError expectedError:NSError?, when action:() -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        var receivedError: Error?

        let exp = expectation(description: "Wait for completion")
        sut.addFavourite(uniqueMovieItem()) { error in
            receivedError = error
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
}
