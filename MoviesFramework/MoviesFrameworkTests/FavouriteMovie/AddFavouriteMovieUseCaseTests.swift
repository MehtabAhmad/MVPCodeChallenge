//
//  AddFavouriteMovieUseCaseTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 03/01/2023.
//

import XCTest
import MoviesFramework

protocol MovieStore {
    typealias insertionCompletion = (Error?) -> Void
    func insert(_ movie:DomainMovie, completion:@escaping insertionCompletion)
}

class AddFavouriteMovieUseCaseHandler {
    let store:MovieStore
    
    init(store:MovieStore) {
        self.store = store
    }
    
    func addFavourite(_ movie:DomainMovie, completion:@escaping (Error?) -> Void) {
        store.insert(movie, completion: completion)
    }
}

final class AddFavouriteMovieUseCaseTests: XCTestCase {

    func test_init_doesnotMessageStore() {
        let (_,store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_addFavourite_requestsMovieInsertion() {
        let (sut,store) = makeSUT()
        let item = uniqueMovieItem()
        sut.addFavourite(item) { _ in }
        XCTAssertEqual(store.receivedMessages, [.insert(item)])
    }
    
    func test_addFavourite_deliversErrorOnInsertionError() {
        let (sut,store) = makeSUT()
        let item = uniqueMovieItem()
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for completion")
        sut.addFavourite(item) { error in
            receivedError = error
            exp.fulfill()
        }
        
        let error = anyNSError()
        store.completeInsertion(with: error)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, error)
    }
    
    // MARK: - Helper
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:AddFavouriteMovieUseCaseHandler, store:MovieStoreSpy) {
        let store = MovieStoreSpy()
        let sut = AddFavouriteMovieUseCaseHandler(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut,store)
    }
    
    private func uniqueMovieItem() -> DomainMovie {
        DomainMovie(
            id: UUID().hashValue,
            title: "a title",
            description: "a description",
            poster: URL(string: "http://a-url.com")!,
            rating: 3.5)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private class MovieStoreSpy: MovieStore {
        
        enum Messages: Equatable {
            case insert(DomainMovie)
        }
        
        var receivedMessages = [Messages]()
        var insertionCompletions = [(Error?) -> Void]()
        
        func insert(_ movie:DomainMovie, completion:@escaping insertionCompletion) {
            receivedMessages.append(.insert(movie))
            insertionCompletions.append(completion)
        }
        func completeInsertion(with error:NSError, at index:Int = 0) {
            insertionCompletions[index](error)
        }
    }
}
