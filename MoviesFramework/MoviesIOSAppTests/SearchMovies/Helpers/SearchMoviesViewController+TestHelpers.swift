//
//  SearchMoviesViewController+TestHelpers.swift
//  MoviesIOSAppTests
//
//  Created by Mehtab on 13/01/2023.
//

import Foundation
import UIKit
import MoviesIOSApp

extension SearchMoviesViewController {
    
    @discardableResult
    func simulateUserInitiatedSearch(with text: String = "any-text") -> Bool {
        setSearchText(text)
        return ((searchBar.delegate?.textFieldShouldReturn?(searchBar)) != nil)
    }
    
    private func setSearchText(_ text:String) {
        searchBar.text = text
    }
    
    var isShowingLoadingIndicator:Bool {
        return searchResultsTableView.refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedMovies() -> Int {
        return searchResultsTableView.numberOfRows(inSection: moviesSection)
    }
    
    func movieCell(at row: Int) -> UITableViewCell? {
        let ds = searchResultsTableView.dataSource
        let index = IndexPath(row: row, section: moviesSection)
        return ds?.tableView(searchResultsTableView, cellForRowAt: index)
    }
    
    private var moviesSection: Int {
        return 0
    }
    
    @discardableResult
    func simulateMovieCellVisible(at index: Int) -> SearchMovieCell? {
        let cell = movieCell(at: index) as? SearchMovieCell
        return cell
    }
    
    @discardableResult
    func simulateMovieCellNotVisible(at row: Int) -> SearchMovieCell? {
        let cell = simulateMovieCellVisible(at: row)
        let delegate = searchResultsTableView.delegate
        let index = IndexPath(row: row, section: moviesSection)
        delegate?.tableView?(searchResultsTableView, didEndDisplaying: cell!, forRowAt: index)
        return cell
    }
    
    func simulateMovieImageViewNearVisible(at row: Int) {
        let ds = searchResultsTableView.prefetchDataSource
        let index = IndexPath(row: row, section: moviesSection)
        ds?.tableView(searchResultsTableView, prefetchRowsAt: [index])
    }
    
    func simulateMovieImageViewNotNearVisible(at row: Int) {
        simulateMovieImageViewNearVisible(at: row)
        
        let ds = searchResultsTableView.prefetchDataSource
        let index = IndexPath(row: row, section: moviesSection)
        ds?.tableView?(searchResultsTableView, cancelPrefetchingForRowsAt: [index])
    }
}
