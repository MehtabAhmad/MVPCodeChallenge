//
//  SearchMoviesViewControllerComposer.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 15/01/2023.
//

import Foundation
import UIKit
import MoviesFramework

public final class SearchMoviesViewControllerComposer {
    
    private init() {}
    
    public static func compose(moviesLoader:LoadMovieUseCase, hideMovieHandler:HideMovieFromSearchUseCase, favouriteMovieHandler:AddFavouriteMovieUseCase, imageLoader: ImageDataLoader) -> SearchMoviesViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            identifier: String(describing: SearchMoviesViewController.self)) as! SearchMoviesViewController
        
        let moviesViewModel = MoviesViewModel(moviesLoader: MainQueueDispatchDecorator(decoratee: moviesLoader))
        
        moviesViewModel.onMoviesLoad = adaptMoviesToCellControllers(forwardingTo: viewController, imageLoader: imageLoader, hideMovieHandler: hideMovieHandler, favouriteMovieHandler: favouriteMovieHandler)
        
        let refreshController = MovieRefreshController(moviesViewModel: moviesViewModel)
       
        viewController.refreshController = refreshController
        
        return viewController
    }
    
    
    private static func adaptMoviesToCellControllers(forwardingTo viewController: SearchMoviesViewController, imageLoader: ImageDataLoader, hideMovieHandler:HideMovieFromSearchUseCase, favouriteMovieHandler:AddFavouriteMovieUseCase) -> ([DomainMovie]) -> Void {
        
        return { [weak viewController] movies in
            viewController?.tableModel = movies.map {
                
                let cellViewModel = MoviesCellViewModel(model: $0, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader), hideMovieHandler: MainQueueDispatchDecorator(decoratee: hideMovieHandler), favouriteMovieHandler: MainQueueDispatchDecorator(decoratee: favouriteMovieHandler), imageTransformer: UIImage.init)
                
                cellViewModel.onLoadingStateChange = viewController?.loadingObserver
                cellViewModel.hideMovieCompletion = hideMovieCompletion(for: viewController)
                
                let controller = SearchMovieCellController(viewModel: cellViewModel)
                
                return controller
            }
        }
    }
    
    private static func hideMovieCompletion(for viewController:SearchMoviesViewController?) -> (Result<IndexPath, Error>) -> Void {
        return { [weak viewController] result in
            guard let indexPath = try? result.get() else { return }
            viewController?.tableModel.remove(at: indexPath.row)
        }
    }
}

private final class MainQueueDispatchDecorator<T> {
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

