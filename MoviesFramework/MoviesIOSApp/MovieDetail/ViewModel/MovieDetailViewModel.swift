//
//  MovieDetailViewModel.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 19/01/2023.
//

import Foundation
import MoviesFramework


class MovieDetailViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var model: DomainMovie
    private let imageLoader: ImageDataLoader
    private var task: ImageDataLoaderTask?
    private let imageTransformer: (Data) -> Image?
    
    var onImageLoadingStateChange:Observer<Bool>?
    
    var onImageLoaded:Observer<Image>?
    
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
        return model.isFavourite
    }
    
    var favouriteImageName:String {
        model.isFavourite ? "favourite_selected" : "favourite_unselected"
    }
    
    init(model: DomainMovie, imageLoader: ImageDataLoader, task: ImageDataLoaderTask? = nil, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.task = task
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
    
    func cancelLoad() {
        task?.cancel()
        task = nil
    }
}

