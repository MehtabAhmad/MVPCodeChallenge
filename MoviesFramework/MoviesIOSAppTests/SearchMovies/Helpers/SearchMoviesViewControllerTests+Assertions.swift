//
//  SearchMoviesViewControllerTests+Assertions.swift
//  MoviesIOSAppTests
//
//  Created by Mehtab on 13/01/2023.
//

import XCTest
import MoviesIOSApp
import MoviesFramework

extension SearchMoviesViewControllerTests {
    
    func assertThat(_ sut: SearchMoviesViewController, hasCellConfiguredFor movie: DomainMovie, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.movieCell(at: index)
        
        guard let cell = view as? SearchMovieCell else {
            return XCTFail("Expected \(SearchMovieCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.titleText, movie.title, "Expected title text \(movie.title) for movie at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, movie.description, "Expected description text \(movie.description) for movie at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.ratingText, "Rating: \(movie.rating)", "Expected rating text \(movie.rating) for movie at index (\(index))", file: file, line: line)
        
        let shouldDoNotShowAgainButtonBeVisible = !movie.isFavourite
        XCTAssertEqual(cell.isDoNotShowAgainButtonShowing, shouldDoNotShowAgainButtonBeVisible, "Expected 'isDoNotShowAgainButtonShowing' to be \(shouldDoNotShowAgainButtonBeVisible) for movie at index (\(index))", file: file, line: line)
        
        let shouldFavouriteButtonBeHighlighted = movie.isFavourite
        XCTAssertEqual(cell.isFavouriteButtonHighlighted, shouldFavouriteButtonBeHighlighted, "Expected 'isFavouriteButtonHeighlighted' to be \(shouldFavouriteButtonBeHighlighted) for movie at index (\(index))", file: file, line: line)
        
        let shouldFavouriteButtonBeEnabled = !movie.isFavourite
        XCTAssertEqual(cell.isFavouriteButtonEnabled, shouldFavouriteButtonBeEnabled, "Expected 'isFavouriteButtonEnabled' to be \(shouldFavouriteButtonBeEnabled) for movie at index (\(index))", file: file, line: line)
        
    }
    
    func assertThat(_ sut: SearchMoviesViewController, isRendering movies: [DomainMovie], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedMovies() == movies.count else {
            return XCTFail("Expected \(movies.count) movies, got \(sut.numberOfRenderedMovies()) instead.", file: file, line: line)
        }
        
        movies.enumerated().forEach { index, movie in
            assertThat(sut, hasCellConfiguredFor: movie, at: index, file: file, line: line)
        }
    }
}
