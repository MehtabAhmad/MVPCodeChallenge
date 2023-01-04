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
        store.retrieve() { [weak self] result in
            guard self != nil else {return}
            switch result {
            case .empty:
                completion(.success([]))
            case let .found(DTOMovies):
                completion(.success(DTOMovies.toDomainMovies()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

private extension Array where Element == StoreMovieDTO {
    func toDomainMovies() -> [DomainMovie] {
        return map {
            DomainMovie(id: $0.id, title: $0.title, description: $0.description, poster: $0.poster, rating: $0.rating)
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
        var sut:FavouriteMovieLoader? = FavouriteMovieLoader(store: store)
        var receivedResult:LoadMovieResult?
        
        sut?.load() { result in
            receivedResult = result
        }
        
        sut = nil
        store.completeRetrivalWithEmptyList()
        
        XCTAssertNil(receivedResult)
    }
    

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:FavouriteMovieLoader, store:MovieStoreSpy) {
        let store = MovieStoreSpy()
        let sut = FavouriteMovieLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut,store)
    }
    
    private func expect(_ sut:FavouriteMovieLoader, toCompleteWith expectedResult:LoadMovieResult, when action:() -> Void, file: StaticString = #file, line: UInt = #line) {

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
