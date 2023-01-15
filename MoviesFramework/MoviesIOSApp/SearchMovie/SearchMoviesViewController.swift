//
//  SearchMoviesViewController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 11/01/2023.
//

import UIKit
import MoviesFramework


public final class SearchMoviesViewControllerComposer {
    
    public static func compose(moviesLoader:LoadMovieUseCase, hideMovieHandler:HideMovieFromSearchUseCase, favouriteMovieHandler:AddFavouriteMovieUseCase, imageLoader: ImageDataLoader) -> SearchMoviesViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            identifier: String(describing: SearchMoviesViewController.self)) as! SearchMoviesViewController
                
        let refreshController = MovieRefreshController(loader: moviesLoader)
        refreshController.onRefresh = adaptMoviesToCellControllers(forwardingTo: viewController, imageLoader: imageLoader, hideMovieHandler: hideMovieHandler, favouriteMovieHandler: favouriteMovieHandler)
        
        viewController.refreshController = refreshController
        
        return viewController
    }
    
    
    private static func adaptMoviesToCellControllers(forwardingTo viewController: SearchMoviesViewController, imageLoader: ImageDataLoader, hideMovieHandler:HideMovieFromSearchUseCase, favouriteMovieHandler:AddFavouriteMovieUseCase) -> ([DomainMovie]) -> Void {
        
        return { [weak viewController] movies in
            viewController?.tableModel = movies.map {
                
                let controller = SearchMovieCellController(movie: $0, imageLoader: imageLoader, hideMovieHandler: hideMovieHandler, favouriteMovieHandler: favouriteMovieHandler)
                
                controller.isLoading = viewController?.loadingObserver
                
                controller.hideMovieCompletion = hideMovieCompletion(for: viewController)
                controller.favouriteMovieCompletion = favouriteMovieCompletion(for: viewController)
               
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
    
    private static func favouriteMovieCompletion(for viewController:SearchMoviesViewController?) -> (Result<SearchMovieCellController, Error>) -> Void {
        return { [weak viewController] result in
            guard let controller = try? result.get() else { return }
            viewController?.tableModel.filter({$0 === controller }).first?.model.isFavourite = true
        }
    }
}


public final class SearchMoviesViewController: UIViewController {
    
    @IBOutlet public weak private(set) var  searchBar: UITextField!
    @IBOutlet public private(set) weak var searchResultsTableView: UITableView!
        
    var refreshController: MovieRefreshController!
    
    var loadingObserver:((Bool) -> Void)?
    
    var tableModel = [SearchMovieCellController]() {
        didSet {
            searchResultsTableView.reloadData()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        searchResultsTableView.prefetchDataSource = self
        searchBar.delegate = self
        
        setupKeyboardHidding()
        setupRefreshController()
        observeLoading()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func search() {
        guard !(searchBar.text ?? "").isEmpty, refreshController?.isRefreshing == false else { return }
        refreshController?.refresh()
    }
    
    private func setupKeyboardHidding(){
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing)))
        searchResultsTableView.keyboardDismissMode = .onDrag
    }
    
    private func setupRefreshController() {
        searchResultsTableView.refreshControl = refreshController?.view
    }
    
    private func observeLoading() {
        loadingObserver = { [ weak self ] isLoading in
            guard let self = self else {return}
            isLoading ? self.refreshController.beginRefreshing() : self.refreshController.endRefreshing()
        }
    }
    
    private func endRefreshing() {
        refreshController?.endRefreshing()
    }
    
    private func beginRefreshing() {
        refreshController?.beginRefreshing()
    }
    
}

extension SearchMoviesViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        return true
    }
}

extension SearchMoviesViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view(in: tableView)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preLoad()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> SearchMovieCellController {
        return tableModel[indexPath.row]
    }
}
