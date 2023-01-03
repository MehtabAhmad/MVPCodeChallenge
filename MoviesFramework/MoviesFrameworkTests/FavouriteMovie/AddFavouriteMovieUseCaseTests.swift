//
//  AddFavouriteMovieUseCaseTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 03/01/2023.
//

import XCTest

class MovieStore {
    enum Messages {}
    var receivedMessages = [Messages]()
}

class AddFavouriteMovieUseCaseHandler {
    
    init(store:MovieStore) {
        
    }
}

final class AddFavouriteMovieUseCaseTests: XCTestCase {

    func test_init_doesnotMessageStore() {
        let store = MovieStore()
        let sut = AddFavouriteMovieUseCaseHandler(store: store)
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
}
