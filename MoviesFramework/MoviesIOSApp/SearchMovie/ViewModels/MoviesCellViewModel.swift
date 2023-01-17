//
//  SearchMovieCellViewModel.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 15/01/2023.
//

import Foundation
import MoviesFramework

final class MoviesCellViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var model: DomainMovie
    private let imageLoader: ImageDataLoader
    private var task: ImageDataLoaderTask?
    private let hideMovieHandler:HideMovieFromSearchUseCase
    private let favouriteMovieHandler:AddFavouriteMovieUseCase
    private let imageTransformer: (Data) -> Image?
    
    var onLoadingStateChange:Observer<Bool>?
    var onImageLoadingStateChange:Observer<Bool>?
    
    var hideMovieCompletion:Observer<Result<IndexPath, Error>>?
    var favouriteMovieCompletion:Observer<Result<IndexPath, Error>>?
    var onImageLoaded:Observer<Image>?
    var onFavourite:(() -> Void)?
    
    var title: String {
        return model.title
    }
    
    var description: String {
        return model.description
    }
    
    var rating: String {
        return "Rating: \(model.rating)"
    }
    
    var isFavourite: Bool {
        set {
            model.isFavourite = true
            onFavourite?()
        }
        get {
            return model.isFavourite
        }
    }
    
    var favouriteImageName:String {
        model.isFavourite ? "favourite_selected" : "favourite_unselected"
    }
    
    var isFavouriteButtonEnabled:Bool {
        return !model.isFavourite
    }
    
    
    init(model: DomainMovie, imageLoader: ImageDataLoader, task: ImageDataLoaderTask? = nil, hideMovieHandler: HideMovieFromSearchUseCase, favouriteMovieHandler: AddFavouriteMovieUseCase, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.task = task
        self.hideMovieHandler = hideMovieHandler
        self.favouriteMovieHandler = favouriteMovieHandler
        self.imageTransformer = imageTransformer
    }
    
    func loadImageData() {
        if let url = model.poster {
            onImageLoadingStateChange?(true)
            task = imageLoader.loadImageData(from: url) { [weak self] result in
                self?.handle(result)
            }
        }
    }
    
    private func handle(_ result: ImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoaded?(image)
        }
        onImageLoadingStateChange?(false)
    }
    
    func hideMovie(at indexPath: IndexPath) {
        self.onLoadingStateChange?(true)
        self.hideMovieHandler.hide(self.model) { [weak self] error in
            guard let self = self else {return}
            if let error = error {
                self.hideMovieCompletion?(.failure(error))
            } else { self.hideMovieCompletion?(.success(indexPath)) }
            
            self.onLoadingStateChange?(false)
        }
    }
    
    func addMovieToFavourites() {
        self.onLoadingStateChange?(true)
        self.favouriteMovieHandler.addFavourite(self.model) { [weak self] error in
            guard let self = self else {return}
            if error == nil {
                self.isFavourite = true
            }
            self.onLoadingStateChange?(false)
        }
    }
    
    func cancelLoad() {
        task?.cancel()
        task = nil
    }
}
