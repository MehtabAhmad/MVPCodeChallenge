//
//  SearchMoviesViewController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 11/01/2023.
//

import UIKit
import MoviesFramework

public protocol ImageDataLoaderTask {
    func cancel()
}

public protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageDataLoaderTask
}

public final class SearchMoviesViewController: UIViewController {

    @IBOutlet public weak private(set) var  searchBar: UITextField!
    @IBOutlet public private(set) weak var searchResultsTableView: UITableView!
    
    public var moviesLoader:LoadMovieUseCase?
    public var imageLoader: ImageDataLoader?
    public var refreshControl: UIRefreshControl!
    private var tableModel = [DomainMovie]()
    private var tasks = [IndexPath: ImageDataLoaderTask]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        searchResultsTableView.prefetchDataSource = self
        searchBar.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing)))
        
        searchResultsTableView.keyboardDismissMode = .onDrag
        refreshControl = UIRefreshControl()
        searchResultsTableView.refreshControl = refreshControl
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func search() {
        refreshControl?.beginRefreshing()
        moviesLoader?.load() { [weak self] result in
            switch result {
            case let .success(movies):
                self?.tableModel = movies
                self?.searchResultsTableView.reloadData()
            default: break
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
}

extension SearchMoviesViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !(textField.text ?? "").isEmpty && refreshControl.isRefreshing == false {
            search()
        }
        
        return true
    }
}

extension SearchMoviesViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchMovieCell") as! SearchMovieCell
        let cellModel = tableModel[indexPath.row]
        cell.titleLabel.text = cellModel.title
        cell.descriptionLabel.text = cellModel.description
        cell.ratingLabel.text = String(cellModel.rating)
        cell.donotShowAgainButton.isHidden = cellModel.isFavourite
        let favouriteButtonImage = cellModel.isFavourite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        cell.favouriteButton.setImage(favouriteButtonImage, for: .normal)
        cell.movieImageView.image = nil
        cell.movieImageContainer.startShimmering()
        tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.poster) { [weak cell] result in
            let data = try? result.get()
            cell?.movieImageView.image = data.map(UIImage.init) ?? nil
            cell?.movieImageContainer.stopShimmering()
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            _ = imageLoader?.loadImageData(from: cellModel.poster) { _ in }
        }
    }
}

public class SearchMovieCell: UITableViewCell {
    @IBOutlet public private(set) var titleLabel:UILabel!
    @IBOutlet public private(set) var descriptionLabel: UILabel!
    @IBOutlet public private(set) var ratingLabel: UILabel!
    @IBOutlet public private(set) var movieImageContainer: UIView!
    @IBOutlet public private(set) var movieImageView: UIImageView!
    @IBOutlet public private(set) var donotShowAgainButton: UIButton!
    @IBOutlet public private(set) var favouriteButton: UIButton!
}
