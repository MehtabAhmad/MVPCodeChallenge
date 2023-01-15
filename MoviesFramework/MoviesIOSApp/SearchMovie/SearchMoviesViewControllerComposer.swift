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
                
                let controller = SearchMovieCellController(movie: $0, imageLoader: imageLoader, hideMovieHandler: hideMovieHandler, favouriteMovieHandler: favouriteMovieHandler)
                
                controller.isLoading = viewController?.loadingObserver
                
                controller.hideMovieCompletion = hideMovieCompletion(for: viewController)
               
                return controller
            }
        }
    }
    
    private static func hideMovieCompletion(for viewController:SearchMoviesViewController?) -> (Result<SearchMovieCellController, Error>) -> Void {
        return { [weak viewController] result in
            guard let controller = try? result.get() else { return }
            if let index = viewController?.tableModel.firstIndex(where: {$0 === controller }) {
                viewController?.tableModel.remove(at: index)
            }
        }
    }
}
