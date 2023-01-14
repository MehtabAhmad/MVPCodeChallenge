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
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator when when user initiated search request completed successfully")
        
        loader.completeLoadingWithError()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator when when user initiated search request completed with error")
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
    
    
    func test_searchCompletion_renderSuccessfullySearchedMovies() {
        
        let movie0 = makeMovie(title: "a title", description: "a description", poster: URL(string: "any-url")!, rating: 3.5)
        let movie1 = makeMovie(title: "title2", description: "description2", poster: URL(string: "any-url")!, rating: 3.6, favourite: true)
        let movie2 = makeMovie(title: "title3", description: "description3", poster: URL(string: "any-url")!, rating: 3.7)
        let movie3 = makeMovie(title: "title4", description: "description4", poster: URL(string: "any-url")!, rating: 0.0, favourite: true)
        
        let (sut,loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        assertThat(sut, isRendering: [])
        
        loader.completeLoading(with: [movie0], at: 0)
        assertThat(sut, isRendering: [movie0])
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [movie0,movie1,movie2,movie3], at: 1)
        assertThat(sut, isRendering: [movie0,movie1,movie2,movie3])
    }
    
    func test_searchCompletion_doesNotAlterCurrentRenderingStateOnError() {
        
        let movie0 = makeMovie()
        
        let (sut,loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [movie0], at: 0)
        assertThat(sut, isRendering: [movie0])
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoadingWithError(at: 0)
        assertThat(sut, isRendering: [movie0])
        
    }
    
    func test_movieCell_loadsImageURLWhenVisible() {
        let movie0 = makeMovie(poster: URL(string: "any-url-0.com")!)
        let movie1 = makeMovie(poster: URL(string: "any-url-1.com")!)
        
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [movie0, movie1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        sut.simulateMovieCellVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.poster], "Expected first image URL request once first view becomes visible")
        
        sut.simulateMovieCellVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.poster, movie1.poster], "Expected second image URL request once second view also becomes visible")
    }
    
    func test_movieCell_cancelsImageLoadingWhenNotVisibleAnymore() {
        let movie0 = makeMovie()
        let movie1 = makeMovie()
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [movie0, movie1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateMovieCellNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [movie0.poster], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateMovieCellNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [movie0.poster, movie1.poster], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }
    
    func test_movieCellLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [makeMovie(), makeMovie()])
        
        let view0 = sut.simulateMovieCellVisible(at: 0)
        let view1 = sut.simulateMovieCellVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    func test_MovieImageView_rendersImageLoadedFromURL() {
        
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [makeMovie(), makeMovie()])
        
        let view0 = sut.simulateMovieCellVisible(at: 0)
        let view1 = sut.simulateMovieCellVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_movieImageView_preloadsImageURLWhenNearVisible() {
        let movie0 = makeMovie()
        let movie1 = makeMovie()
        
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [movie0, movie1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateMovieImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.poster], "Expected first image URL request once first image is near visible")
        
        sut.simulateMovieImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.poster, movie1.poster], "Expected second image URL request once second image is near visible")
    }
    
    
    func test_movieImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let movie0 = makeMovie()
        let movie1 = makeMovie()
        
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [movie0, movie1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateMovieImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [movie0.poster], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateMovieImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [movie0.poster, movie1.poster], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
    func test_movieCellDoNotShowAgainAction_showLoadingIndicator() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [makeMovie(), makeMovie()])
        
        var cell = sut.simulateMovieCellVisible(at: 0)
        cell?.simulateDoNotShowAgainAction()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator when user tap 'don't show again' button")
        
        loader.completeHideMovieRequestSuccessfully(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator when hide movie request completed successfully")
        
        cell = sut.simulateMovieCellVisible(at: 0)
        cell?.simulateDoNotShowAgainAction()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator when user tap 'don't show again' button")
        
        loader.completeHideMovieRequestWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator when hide movie request completed with error")
    }
    
    func test_movieCellDoNotShowAgainAction_hidesMovieOnSuccess() {
        let (sut, loader) = makeSUT()
        let movie0 = makeMovie()
        let movie1 = makeMovie()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [movie0, movie1])
        
        let cell0 = sut.simulateMovieCellVisible(at: 0)
        _ = sut.simulateMovieCellVisible(at: 1)
        
        cell0?.simulateDoNotShowAgainAction()
        
        loader.completeHideMovieRequestSuccessfully()
        
        assertThat(sut, isRendering: [movie1])
        
    }
    
    func test_movieCellDoNotShowAgainAction_shouldNotHidesMovieOnError() {
        let (sut, loader) = makeSUT()
        let movie0 = makeMovie()
        let movie1 = makeMovie()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [movie0, movie1])
        
        let cell0 = sut.simulateMovieCellVisible(at: 0)
        _ = sut.simulateMovieCellVisible(at: 1)
        
        cell0?.simulateDoNotShowAgainAction()
        
        loader.completeHideMovieRequestWithError()
        
        assertThat(sut, isRendering: [movie0, movie1])
        
    }
    
    func test_movieCellFavouriteAction_showLoadingIndicator() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [makeMovie()])
        
        let cell = sut.simulateMovieCellVisible(at: 0)
        cell?.simulateFavouriteAction()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator when user tap 'favourite' button")
        
        loader.completeFavouriteRequestSuccessfully(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator when favourite movie request completed successfully")
        
        cell?.simulateFavouriteAction()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expect loading indicator when user tap 'favourite' button")
        
        loader.completeFavouriteRequestWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expect no loading indicator when favourite movie request completed with error")
    }
    
    func test_movieCellFavouriteAction_highlightFavouriteOnSuccess() {
        let (sut, loader) = makeSUT()
       
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [makeMovie()])
        
        var cell0 = sut.simulateMovieCellVisible(at: 0)
        
        cell0?.simulateFavouriteAction()
        XCTAssertEqual(cell0?.isFavouriteButtonHighlighted, false)
        
        loader.completeFavouriteRequestSuccessfully()
        
        cell0 = sut.simulateMovieCellVisible(at: 0)
        XCTAssertEqual(cell0?.isFavouriteButtonHighlighted, true)
    }
    
    func test_movieCellFavouriteAction_shouldHideDoNoShowAgainButtonOnFavouriteSuccess() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [makeMovie()])
        
        var cell0 = sut.simulateMovieCellVisible(at: 0)
        
        cell0?.simulateFavouriteAction()
        XCTAssertEqual(cell0?.isDoNotShowAgainButtonShowing, true)
        
        loader.completeFavouriteRequestSuccessfully()
        
        cell0 = sut.simulateMovieCellVisible(at: 0)
        XCTAssertEqual(cell0?.isDoNotShowAgainButtonShowing, false)
    }
    
    func test_movieCellFavouriteAction_shouldNotHideDoNoShowAgainButtonOnFavouriteFailure() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [makeMovie()])
        
        var cell0 = sut.simulateMovieCellVisible(at: 0)
        
        cell0?.simulateFavouriteAction()
        XCTAssertEqual(cell0?.isDoNotShowAgainButtonShowing, true)
        
        loader.completeFavouriteRequestWithError()
        
        cell0 = sut.simulateMovieCellVisible(at: 0)
        XCTAssertEqual(cell0?.isDoNotShowAgainButtonShowing, true)
    }
    
    func test_movieCellFavouriteAction_shouldNotHighlightFavouriteOnFailure() {
        let (sut, loader) = makeSUT()
        let movie0 = makeMovie()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [movie0])
        
        let cell0 = sut.simulateMovieCellVisible(at: 0)
        
        cell0?.simulateFavouriteAction()
        XCTAssertEqual(cell0?.isFavouriteButtonHighlighted, false)
        
        loader.completeFavouriteRequestWithError()
        XCTAssertEqual(cell0?.isFavouriteButtonHighlighted, false)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut:SearchMoviesViewController, loader:LoaderSpy) {
        let loader = LoaderSpy()
        
        let sut = SearchMoviesViewControllerComposer.compose(moviesLoader: loader, hideMovieHandler: loader, favouriteMovieHandler: loader, imageLoader: loader)
        sut.loadViewIfNeeded()
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return(sut,loader)
    }
    
    private func makeMovie(title: String = UUID().uuidString, description: String = UUID().uuidString, poster: URL = URL(string: "\(UUID().uuidString).com")!, rating: Float = 0.0, favourite:Bool = false) -> DomainMovie {
        
        return DomainMovie(id: UUID().hashValue, title: title, description: description, poster: poster, rating: rating, isFavourite: favourite)
    }
}

