//
//  AddFavouriteMovieUseCaseTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 03/01/2023.
//

import XCTest
import MoviesFramework

class MovieStore {
    enum Messages: Equatable {
        case insert(DomainMovie)
    }
    var receivedMessages = [Messages]()
    
    func insert(_ movie:DomainMovie) {
        receivedMessages.append(.insert(movie))
    }
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
        let store = MovieStore()
        let sut = AddFavouriteMovieUseCaseHandler(store: store)
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_addFavourite_requestsMovieInsertion() {
        let store = MovieStore()
        let sut = AddFavouriteMovieUseCaseHandler(store: store)
        let item = uniqueMovieItem()
        sut.addFavourite(item)
        XCTAssertEqual(store.receivedMessages, [.insert(item)])
    }
    
    
    // Mark: - Helper
    
    private func uniqueMovieItem() -> DomainMovie {
        DomainMovie(
            id: UUID().hashValue,
            title: "a title",
            description: "a description",
            poster: URL(string: "http://a-url.com")!,
            rating: 3.5)
    }
}
