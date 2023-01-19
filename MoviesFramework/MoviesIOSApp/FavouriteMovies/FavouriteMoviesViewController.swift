//
//  FavouriteMoviesViewController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 11/01/2023.
//

import UIKit

public class FavouriteMoviesViewController: UITableViewController, UITableViewDataSourcePrefetching {
        
    var searchAction:(() -> Void)?
    
    var viewModel:MoviesViewModel?
    
    var tableModel = [FavouriteMovieCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        tableView.prefetchDataSource = self
        loadFavourite()
    }

    public func loadFavourite() {
        viewModel?.loadMovie()
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        searchAction?()
    }
}

extension FavouriteMoviesViewController {
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath)!.view(in: tableView, at: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath)?.preLoad()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.cancelLoad()
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FavouriteMovieCellController? {
        guard tableModel.count > indexPath.row else { return nil }
        return tableModel[indexPath.row]
    }
}
