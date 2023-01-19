//
//  FavouriteMoviesViewControllerComposer.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 17/01/2023.
//

import Foundation

import Foundation
import UIKit
import MoviesFramework
import CoreData

public final class FavouriteMoviesViewControllerComposer {
    
    private init() {}
    
    public static func compose(moviesLoader:LoadMovieUseCase, imageLoader: ImageDataLoader) -> FavouriteMoviesViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            identifier: String(describing: FavouriteMoviesViewController.self)) as! FavouriteMoviesViewController
        
        let moviesViewModel = MoviesViewModel(moviesLoader: MainQueueDispatchDecorator(decoratee: moviesLoader))
        
        moviesViewModel.onMoviesLoad = { [weak viewController] result in
            switch result {
            case let .success(movies):
                adaptMoviesToCellControllers(movies, forwardingTo: viewController, imageLoader: imageLoader)
                break
            default:break
            }
        }
        
        viewController.searchAction = { [weak viewController] in
            let vc = makeDestination()
            vc.modalPresentationStyle = .fullScreen
            viewController?.present(vc, animated: true)
        }
        
        viewController.viewModel = moviesViewModel
        
        return viewController
    }
    
    private static func adaptMoviesToCellControllers(_ movies: [DomainMovie], forwardingTo viewController: FavouriteMoviesViewController?, imageLoader: ImageDataLoader) {
        
        viewController?.tableModel = movies.map {
            
            let cellViewModel = FavouriteCellViewModel(model: $0, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader), imageTransformer: UIImage.init, cellTapAction: cellTapAction(in: viewController))
            
            let controller = FavouriteMovieCellController(viewModel: cellViewModel)
            
            return controller
        }
    }
    
    private static func cellTapAction(in vc:FavouriteMoviesViewController?) -> (DomainMovie) -> Void {
        return { [weak vc] model in
            vc?.present(makeDetailVC(with: model), animated: true)
        }
    }
    
    
    private static func makeDetailVC(with model: DomainMovie) -> MovieDetailViewController {
        
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let imageLoader = RemoteMovieImageDataLoader(client: client, baseUrl: "https://image.tmdb.org/t/p/w500/")
        
        return DetailViewControllerComposer.compose(model: model, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
    }
    
    private static func makeDestination() -> SearchMoviesViewController  {
        let url = "https://api.themoviedb.org/3/search/movie?api_key=08d9aa3c631fbf207d23d4be591ccfc3&language=en-US&page=1&include_adult=false&query="
        
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)
        config.urlCache = nil
        
        let client = URLSessionHTTPClient(session: session)
        let remoteLoader = RemoteMovieLoader(client: client)
        let imageLoader = RemoteMovieImageDataLoader(client: client, baseUrl: "https://image.tmdb.org/t/p/w500/")
        
        lazy var store: CoreDataMoviesStore = {
            try! CoreDataMoviesStore(
                storeURL: NSPersistentContainer
                    .defaultDirectoryURL()
                    .appendingPathComponent("movie-store.sqlite"))
        }()
        
        let hideHandler = HideMovieFromSearchUseCaseHandler(store: store)
        let favouriteHandler = AddFavouriteMovieUseCaseHandler(store: store)
        
        let favouriteLoader = FavouriteMovieLoader(store: store)
        let hideLoader = HiddenMoviesLoader(store: store)
        
        let searchHandler = LoadMoviesCompositeAdapter(remoteLoader: remoteLoader, favouriteLoader: favouriteLoader, hiddenLoader: hideLoader)
        
        let vc = SearchMoviesViewControllerComposer.compose(moviesLoader: searchHandler, hideMovieHandler: hideHandler, favouriteMovieHandler: favouriteHandler, imageLoader: imageLoader)
        
        let urlProvider = { [weak vc] in
            let query = vc? .searchBar.text!.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            return URL(string:"\(url)\(query ?? "")")!
        }
        
        remoteLoader.provideUrl = urlProvider
        
        return vc
    }
}
