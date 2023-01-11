//
//  MoviesIOSAppTests.swift
//  MoviesIOSAppTests
//
//  Created by Mehtab on 11/01/2023.
//

import XCTest
import MoviesFramework
import MoviesIOSApp

final class SearchMoviesViewControllerTests: XCTestCase {

    func test_init_doesNotInvokeSearch() {
        let loader = LoaderSpy()
        let _ = SearchMoviesViewController(loader:loader)
        XCTAssertEqual(loader.searchCallCount, 0)
    }
    
    func test_viewDidLoad_doesNotInvokeSearch() {
        let loader = LoaderSpy()
        let _ = SearchMoviesViewController(loader:loader)
        XCTAssertEqual(loader.searchCallCount, 0)
    }

    
    private class LoaderSpy:LoadMovieUseCase {
        
        func load(completion: @escaping (MoviesFramework.LoadMovieResult) -> Void) {
        }
        var searchCallCount = 0
    }
}
