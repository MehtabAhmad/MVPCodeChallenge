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
        let exp = expectation(description: "wait for completion")
        sut.load() { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure found \(result) instead")
            }
            exp.fulfill()
        }
        
        let retrievalError = anyNSError()
        store.completeRetrival(with: retrievalError)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }
    
    
    func test_load_deliversEmptyListWhenThereAreNoFavouriteMovies() {
        let (sut,store) = makeSUT()
        
        var receivedMovies:[DomainMovie]?
        let exp = expectation(description: "wait for completion")
        sut.load() { result in
            switch result {
            case let .success(movies):
                receivedMovies = movies
            default:
                XCTFail("Expected success got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrivalWithEmptyList()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedMovies, [])
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
