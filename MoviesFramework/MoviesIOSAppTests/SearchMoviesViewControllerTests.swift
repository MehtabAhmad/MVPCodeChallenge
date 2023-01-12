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
        
        let movie0 = makeMovie(title: "a title", description: "a description", poster: URL(string: "any-url")!, rating: 3.5)
   
        let (sut,loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [movie0], at: 0)
        assertThat(sut, isRendering: [movie0])
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoadingWithError(at: 0)
        assertThat(sut, isRendering: [movie0])
     
    }
    
    func test_movieCell_loadsImageURLWhenVisible() {
        let movie0 = makeMovie(title: "a title", description: "a description", poster: URL(string: "any-url-0.com")!, rating: 3.5)
        let movie1 = makeMovie(title: "title2", description: "description2", poster: URL(string: "any-url-1.com")!, rating: 3.6, favourite: true)
        
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
        let movie0 = makeMovie(title: "a title", description: "a description", poster: URL(string: "any-url-0.com")!, rating: 3.5)
        let movie1 = makeMovie(title: "title2", description: "description2", poster: URL(string: "any-url-1.com")!, rating: 3.6, favourite: true)
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
        let movie0 = makeMovie(title: "a title", description: "a description", poster: URL(string: "any-url-0.com")!, rating: 3.5)
        let movie1 = makeMovie(title: "title2", description: "description2", poster: URL(string: "any-url-1.com")!, rating: 3.6, favourite: true)
        
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [movie0, movie1])
        
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
        
        let movie0 = makeMovie(title: "a title", description: "a description", poster: URL(string: "any-url-0.com")!, rating: 3.5)
        let movie1 = makeMovie(title: "title2", description: "description2", poster: URL(string: "any-url-1.com")!, rating: 3.6, favourite: true)
        
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedSearch()
        loader.completeLoading(with: [movie0, movie1])
        
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
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut:SearchMoviesViewController, loader:LoaderSpy) {
        let loader = LoaderSpy()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sut = storyboard.instantiateViewController(
            identifier: String(describing: SearchMoviesViewController.self)) as! SearchMoviesViewController
        sut.moviesLoader = loader
        sut.imageLoader = loader
        sut.loadViewIfNeeded()
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return(sut,loader)
    }
    
    private func makeMovie(title: String, description: String, poster: URL, rating: Float, favourite:Bool = false) -> DomainMovie {
        
        return DomainMovie(id: UUID().hashValue, title: title, description: description, poster: poster, rating: rating, isFavourite: favourite)
    }
    
    
    private func assertThat(_ sut: SearchMoviesViewController, hasCellConfiguredFor movie: DomainMovie, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.movieCell(at: index)
        
        guard let cell = view as? SearchMovieCell else {
            return XCTFail("Expected \(SearchMovieCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.titleText, movie.title, "Expected title text \(movie.title) for movie at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, movie.description, "Expected description text \(movie.description) for movie at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.ratingText, String(movie.rating), "Expected rating text \(movie.rating) for movie at index (\(index))", file: file, line: line)
        
        let shouldDoNotShowAgainButtonBeVisible = !movie.isFavourite
        XCTAssertEqual(cell.isDoNotShowAgainButtonShowing, shouldDoNotShowAgainButtonBeVisible, "Expected 'isDoNotShowAgainButtonShowing' to be \(shouldDoNotShowAgainButtonBeVisible) for movie at index (\(index))", file: file, line: line)
        
        let shouldFavouriteButtonBeHighlighted = movie.isFavourite
        XCTAssertEqual(cell.isFavouriteButtonHighlighted, shouldFavouriteButtonBeHighlighted, "Expected 'isFavouriteButtonHeighlighted' to be \(shouldFavouriteButtonBeHighlighted) for movie at index (\(index))", file: file, line: line)
        
    }
    
    private func assertThat(_ sut: SearchMoviesViewController, isRendering movies: [DomainMovie], file: StaticString = #file, line: UInt = #line) {
            guard sut.numberOfRenderedMovies() == movies.count else {
                return XCTFail("Expected \(movies.count) movies, got \(sut.numberOfRenderedMovies()) instead.", file: file, line: line)
            }
            
            movies.enumerated().forEach { index, movie in
                assertThat(sut, hasCellConfiguredFor: movie, at: index, file: file, line: line)
            }
        }
    
    private class LoaderSpy:LoadMovieUseCase, ImageDataLoader {
        
        typealias LoadResult = MoviesFramework.LoadMovieResult
        
        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        var searchCallCount:Int {
            movieLoadingCompletions.count
        }
        
        private var movieLoadingCompletions = [(LoadResult) -> Void]()
        private var imageRequests = [(url: URL, completion: (ImageDataLoader.Result) -> Void)]()
        
        func load(completion: @escaping (LoadResult) -> Void) {
            movieLoadingCompletions.append(completion)
        }
        
        func completeLoading(with movies:[DomainMovie] = [], at index:Int = 0) {
            movieLoadingCompletions[index](.success(movies))
        }
        
        func completeLoadingWithError(at index:Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            movieLoadingCompletions[index](.failure(error))
        }
        
        private struct TaskSpy: ImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
            imageRequests.append((url,completion))
            return TaskSpy { [weak self ] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with imageData:Data = Data(), at index:Int) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
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
    
    func simulateMovieCellNotVisible(at row: Int) {
        let cell = simulateMovieCellVisible(at: row)
        let delegate = searchResultsTableView.delegate
        let index = IndexPath(row: row, section: moviesSection)
        delegate?.tableView?(searchResultsTableView, didEndDisplaying: cell!, forRowAt: index)
    }
}

private extension SearchMovieCell {
    var titleText:String? {
        return titleLabel.text
    }
    
    var descriptionText:String? {
        return descriptionLabel.text
    }
    
    var ratingText:String? {
        return ratingLabel.text
    }
    
    var isDoNotShowAgainButtonShowing:Bool {
        return !donotShowAgainButton.isHidden
    }
    
    var isFavouriteButtonHighlighted:Bool {
        return favouriteButton.currentImage === UIImage(systemName: "heart.fill")
    }
    
    var isShowingImageLoadingIndicator:Bool {
        return movieImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        return movieImageView.image?.pngData()
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}

