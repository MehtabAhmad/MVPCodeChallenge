//
//  AddFavouriteMovieUseCaseTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 03/01/2023.
//

import XCTest
import MoviesFramework

protocol MovieStore {
    
    func insert(_ movie:DomainMovie)
}

class AddFavouriteMovieUseCaseHandler {
    let store:MovieStore
    
    init(store:MovieStore) {
        self.store = store
    }
    
    func addFavourite(_ movie:DomainMovie) {
        store.insert(movie)
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
        sut.addFavourite(item)
        XCTAssertEqual(store.receivedMessages, [.insert(item)])
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
    
    private class MovieStoreSpy: MovieStore {
        
        enum Messages: Equatable {
            case insert(DomainMovie)
        }
        
        var receivedMessages = [Messages]()
        
        func insert(_ movie:DomainMovie) {
            receivedMessages.append(.insert(movie))
        }
    }
}
