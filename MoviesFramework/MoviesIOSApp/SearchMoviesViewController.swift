//
//  SearchMoviesViewController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 11/01/2023.
//

import UIKit
import MoviesFramework

public final class SearchMoviesViewController: UIViewController {

    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    private var moviesLoader:LoadMovieUseCase?
    
    public convenience init(loader: LoadMovieUseCase) {
        self.init()
        self.moviesLoader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing)))
        
        searchResultsTableView.keyboardDismissMode = .onDrag

        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
}

extension SearchMoviesViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchMovieCell") as! MovieCell
        cell.fadeIn(UIImage(named: "image-\(indexPath.row)"))
        return cell
    }
}
