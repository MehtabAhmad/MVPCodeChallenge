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

    
    func test_viewDidLoad_doesNotInvokeSearch() {
        let (_,loader) = makeSUT()
        XCTAssertEqual(loader.searchCallCount, 0)
    }
    
    func test_searchFiedlDelegates_shouldBeConnected() {
        let (sut,_) = makeSUT()
        XCTAssertNotNil(sut.searchBar.delegate, "SearchField delegates")
    }
    
    func test_userInitiatedSearch_doesNotInvokeSearchWhenSearchFieldIsEmpty() {
        let (sut,loader) = makeSUT()
        let emptyText = ""
        sut.simulateUserInitiatedSearch(with: emptyText)
        XCTAssertEqual(loader.searchCallCount, 0)
    }
    
    func test_userInitiatedSearch_invokeSearchWhenSearchFieldIsNotEmpty() {
        let (sut,loader) = makeSUT()
        sut.simulateUserInitiatedSearch()
        XCTAssertEqual(loader.searchCallCount, 1)
    }
    

    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut:SearchMoviesViewController, loader:LoaderSpy) {
        let loader = LoaderSpy()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sut = storyboard.instantiateViewController(
        identifier: String(describing: SearchMoviesViewController.self)) as! SearchMoviesViewController
        sut.moviesLoader = loader
        sut.loadViewIfNeeded()
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return(sut,loader)
    }
    
    private class LoaderSpy:LoadMovieUseCase {
        
        var searchCallCount = 0
        
        func load(completion: @escaping (MoviesFramework.LoadMovieResult) -> Void) {
            searchCallCount += 1
        }
    }
}

private extension SearchMoviesViewController {
    
    @discardableResult
    func simulateUserInitiatedSearch(with text: String = "any-text") -> Bool {
        setSearchText(text)
        return ((searchBar.delegate?.textFieldShouldReturn?(searchBar)) != nil)
    }
    
    private func setSearchText(_ text:String) {
        searchBar.text = text
    }
}

