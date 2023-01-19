//
//  SearchMoviesViewControllerTests+LoaderSpy.swift
//  MoviesIOSAppTests
//
//  Created by Mehtab on 13/01/2023.
//

import Foundation
import MoviesIOSApp
import MoviesFramework

class LoaderSpy:LoadMovieUseCase, ImageDataLoader, HideMovieFromSearchUseCase, AddFavouriteMovieUseCase {
    
    typealias LoadResult = MoviesFramework.LoadMovieResult
    
    var searchCallCount:Int {
        movieLoadingCompletions.count
    }
    
    private var movieLoadingCompletions = [(LoadResult) -> Void]()
    
    
    func load(completion: @escaping (LoadResult) -> Void) {
        movieLoadingCompletions.append(completion)
    }
    
    func completeLoading(with movies:[DomainMovie] = [], at index:Int = 0) {        movieLoadingCompletions[index](.success(movies))
    }
    
    func completeLoadingWithError(at index:Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        movieLoadingCompletions[index](.failure(error))
    }
    
    // MARK: - ImageLoader
    
    private var imageRequests = [(url: URL, completion: (ImageDataLoader.Result) -> Void)]()
    
    var loadedImageURLs: [URL] {
        return imageRequests.map { $0.url }
    }
    
    private(set) var cancelledImageURLs = [URL]()
    
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
    
    
    // MARK: - HideMovieUseCase
    
    var hideMovieRequests = [(hideMovieResult) -> Void]()
    
    func hide(_ movie: DomainMovie, completion: @escaping (hideMovieResult) -> Void) {
        hideMovieRequests.append(completion)
    }
    
    func completeHideMovieRequestSuccessfully(at index:Int = 0){
        hideMovieRequests[index](nil)
    }
    
    func completeHideMovieRequestWithError(at index:Int = 0){
        let error = NSError(domain: "an error", code: 0)
        hideMovieRequests[index](error)
    }
    
    
    // MARK: - FavouriteMovieUseCase
    
    var favouriteRequests = [(addFavouriteResult) -> Void]()
    
    func addFavourite(_ movie: DomainMovie, completion: @escaping (addFavouriteResult) -> Void) {
        favouriteRequests.append(completion)
    }
    
    func completeFavouriteRequestSuccessfully(at index:Int = 0){
        favouriteRequests[index](nil)
    }
    
    func completeFavouriteRequestWithError(at index:Int = 0){
        let error = NSError(domain: "an error", code: 0)
        favouriteRequests[index](error)
    }
}
