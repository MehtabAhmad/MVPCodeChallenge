//
//  SearchMoviesViewController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 11/01/2023.
//

import UIKit

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
        self.view.endEditing(true)
    }
    
    private func setupKeyboardHidding(){
        //view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing)))
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
        cellController(forRowAt: indexPath)!.view(in: tableView, at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.tapCell()
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.cancelLoad()
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> SearchMovieCellController? {
        guard tableModel.count > indexPath.row else { return nil }
        return tableModel[indexPath.row]
    }
}
