//
//  LoadHiddenMoviesUseCaseTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 04/01/2023.
//

import XCTest
import MoviesFramework

final class LoadHiddenMoviesUseCaseTests: XCTestCase {

    func test_init_doesnotMessageStore() {
        let (_,store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_load_requestsRetrieve() {
        let (sut,store) = makeSUT()
        sut.load() { _ in }
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_deliversErrorOnRetrievalError() {
        let (sut,store) = makeSUT()
        
        let retrievalError = anyNSError()
        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrival(with: retrievalError)
        })
        
    }
    
    func test_load_deliversEmptyListWhenThereAreNoFavouriteMovies() {
        let (sut,store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrivalWithEmptyList()
        })
    }
    
    func test_load_deliversFavouriteMovieListOnSuccessfullRetrieval() {
        let (sut,store) = makeSUT()
        let items = uniqueMovieItemArray()
        
        expect(sut, toCompleteWith: .success(items.model), when: {
            store.completeRetrival(with: items.dto)
        })
    }
    
    func test_load_doesNotDeliverResultWhenSUTInstanceHasBeenDeallocated() {
        let store = MovieStoreSpy()
        var sut:HiddenMoviesLoader? = HiddenMoviesLoader(store: store)
        var receivedResult:LoadMovieResult?
        
        sut?.load() { result in
            receivedResult = result
        }
        
        sut = nil
        store.completeRetrivalWithEmptyList()
        
        XCTAssertNil(receivedResult)
    }
    

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:LoadMovieUseCase, store:MovieStoreSpy) {
        let store = MovieStoreSpy()
        let sut = HiddenMoviesLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut,store)
    }
    
    private func expect(_ sut:LoadMovieUseCase, toCompleteWith expectedResult:LoadMovieResult, when action:() -> Void, file: StaticString = #file, line: UInt = #line) {

        let exp = expectation(description: "wait for completion")
        
        sut.load() { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedMovies), .success(expectedMovies)):
                XCTAssertEqual(receivedMovies, expectedMovies, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
}
