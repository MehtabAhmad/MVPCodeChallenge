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
    
    func load() {
        store.retrieve()
    }
}

final class LoadFavouriteMovieUseCaseTests: XCTestCase {

    func test_init_doesnotMessageStore() {
        let (_,store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_load_requestsRetrieve() {
        let (sut,store) = makeSUT()
        sut.load()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
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
