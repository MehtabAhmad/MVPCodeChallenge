//
//  LoadFavouriteMovieUseCaseTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 04/01/2023.
//

import XCTest
import MoviesFramework

class FavouriteMovieLoader {
    
    let store:MovieStore
    
    init(store: MovieStore) {
        self.store = store
    }
    
    func load(completion:@escaping (LoadMovieResult) -> Void) {
        store.retrieve() { result in
            switch result {
            case .empty:
                completion(.success([]))
            case .found: break
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

final class LoadFavouriteMovieUseCaseTests: XCTestCase {

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
        
        var receivedError:Error?
        
        sut.load() { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure found \(result) instead")
            }
        }
        
        let retrievalError = anyNSError()
        store.completeRetrival(with: retrievalError)
        
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }
    

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:FavouriteMovieLoader, store:MovieStoreSpy) {
        let store = MovieStoreSpy()
        let sut = FavouriteMovieLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut,store)
    }
}
