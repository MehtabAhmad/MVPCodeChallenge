//
//  MainQueueDispatchDecorator.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 15/01/2023.
//

import Foundation
import MoviesFramework

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: LoadMovieUseCase where T == LoadMovieUseCase {
    
    func load(completion: @escaping (LoadMovieResult) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: HideMovieFromSearchUseCase where T == HideMovieFromSearchUseCase {
    
    func hide(_ movie: MoviesFramework.DomainMovie, completion: @escaping (hideMovieResult) -> Void) {
        decoratee.hide(movie) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: AddFavouriteMovieUseCase where T == AddFavouriteMovieUseCase {
    
    func addFavourite(_ movie: MoviesFramework.DomainMovie, completion: @escaping (addFavouriteResult) -> Void) {
        decoratee.addFavourite(movie) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: ImageDataLoader where T == ImageDataLoader {
    
    func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> MoviesFramework.ImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result)
                
            }
        }
    }
}
