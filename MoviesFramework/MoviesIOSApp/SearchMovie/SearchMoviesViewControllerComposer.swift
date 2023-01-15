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
    
    public static func compose(moviesLoader:LoadMovieUseCase, hideMovieHandler:HideMovieFromSearchUseCase, favouriteMovieHandler:AddFavouriteMovieUseCase, imageLoader: ImageDataLoader) -> SearchMoviesViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            identifier: String(describing: SearchMoviesViewController.self)) as! SearchMoviesViewController
        
        let moviesViewModel = MoviesViewModel(moviesLoader: moviesLoader)
        moviesViewModel.onMoviesLoad = adaptMoviesToCellControllers(forwardingTo: viewController, imageLoader: imageLoader, hideMovieHandler: hideMovieHandler, favouriteMovieHandler: favouriteMovieHandler)
        
        let refreshController = MovieRefreshController(moviesViewModel: moviesViewModel)
       
        viewController.refreshController = refreshController
        
        return viewController
    }
    
    
    private static func adaptMoviesToCellControllers(forwardingTo viewController: SearchMoviesViewController, imageLoader: ImageDataLoader, hideMovieHandler:HideMovieFromSearchUseCase, favouriteMovieHandler:AddFavouriteMovieUseCase) -> ([DomainMovie]) -> Void {
        
        return { [weak viewController] movies in
            viewController?.tableModel = movies.map {
                
                let cellViewModel = MoviesCellViewModel(model: $0, imageLoader: imageLoader, hideMovieHandler: hideMovieHandler, favouriteMovieHandler: favouriteMovieHandler, imageTransformer: UIImage.init)
                
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
