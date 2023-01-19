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
                
                let cellViewModel = MoviesCellViewModel(model: $0, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader), hideMovieHandler: MainQueueDispatchDecorator(decoratee: hideMovieHandler), favouriteMovieHandler: MainQueueDispatchDecorator(decoratee: favouriteMovieHandler), imageTransformer: UIImage.init, cellTapAction: cellTapAction(in: viewController))
                
                cellViewModel.onLoadingStateChange = viewController?.loadingObserver
                cellViewModel.hideMovieCompletion = hideMovieCompletion(for: viewController)
                
                let controller = SearchMovieCellController(viewModel: cellViewModel)
                
                return controller
            }
        }
    }
    
    private static func cellTapAction(in vc:SearchMoviesViewController?) -> (DomainMovie) -> Void {
        return { [weak vc] model in
            vc?.show(makeDetailVC(with: model), sender: vc)
        }
    }
    
    
    private static func makeDetailVC(with model: DomainMovie) -> MovieDetailViewController {
        
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let imageLoader = RemoteMovieImageDataLoader(client: client, baseUrl: "https://image.tmdb.org/t/p/w500/")
        
        return DetailViewControllerComposer.compose(model: model, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
    }
    
    private static func hideMovieCompletion(for viewController:SearchMoviesViewController?) -> (Result<IndexPath, Error>) -> Void {
        return { [weak viewController] result in
            guard let indexPath = try? result.get() else { return }
            viewController?.tableModel.remove(at: indexPath.row)
        }
    }
}

