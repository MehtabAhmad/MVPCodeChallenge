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
        XCTAssertEqual(loader.searchCallCount, 0, "Expect no search request when view is loaded")
    }
    
    func test_searchFiedlDelegates_shouldBeConnected() {
        let (sut,_) = makeSUT()
        XCTAssertNotNil(sut.searchBar.delegate, "SearchField delegates")
    }
    
    func test_userInitiatedSearch_doesNotInvokeSearchWhenSearchFieldIsEmpty() {
        let (sut,loader) = makeSUT()
        let emptyText = ""
        sut.simulateUserInitiatedSearch(with: emptyText)
        XCTAssertEqual(loader.searchCallCount, 0, "Expect no search request when search text is empty")
    }
    
    func test_userInitiatedSearch_invokeSearchWhenSearchFieldIsNotEmpty() {
        let (sut,loader) = makeSUT()
        sut.simulateUserInitiatedSearch()
        XCTAssertEqual(loader.searchCallCount, 1, "Expect a search request when user initiated search with some search text")
    }
    
    func test_viewDidLoad_doesNotShowLoadingIndicator() {
        let (sut,_) = makeSUT()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator when view loads")
    }
    
    func test_userInitiatedSearch_showsLoadingIndicator() {
        let (sut,_) = makeSUT()
        sut.simulateUserInitiatedSearch()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator when when user initiated a search request")
    }
    
    func test_userInitiatedSearch_hideLoadingIndicatorOnCompletion() {
        let (sut,loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator when when user initiated a search request")
        
        loader.completeLoading()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator when when user initiated search request has been completed")
    }
    
    func test_userInitiatedSearch_onlyInvokeSearchRequestWhenNoPreviousSearchRunning() {
        let (sut,loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        XCTAssertEqual(loader.searchCallCount, 1, "Expect a search request when user initiated a search")
        
        sut.simulateUserInitiatedSearch()
        XCTAssertEqual(loader.searchCallCount, 1, "Expect no new request when user initiated search before completing the last request")
        
        loader.completeLoading()
        
        sut.simulateUserInitiatedSearch()
        XCTAssertEqual(loader.searchCallCount, 2, "Expect a new request when user initiated search after completing the last request")
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
        
        typealias LoadResult = MoviesFramework.LoadMovieResult
        
        var searchCallCount:Int {
            loadingCompletions.count
        }
        var loadingCompletions = [(LoadResult) -> Void]()
        
        func load(completion: @escaping (LoadResult) -> Void) {
            loadingCompletions.append(completion)
        }
        
        func completeLoading(at index:Int = 0) {
            loadingCompletions[index](.success([]))
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
    
    var isShowingLoadingIndicator:Bool {
        return refreshControl?.isRefreshing == true
    }
}

