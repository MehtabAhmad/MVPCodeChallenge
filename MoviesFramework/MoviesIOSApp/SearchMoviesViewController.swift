//
//  SearchMoviesViewController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 11/01/2023.
//

import UIKit
import MoviesFramework

public final class SearchMoviesViewController: UIViewController {

    @IBOutlet public weak private(set) var  searchBar: UITextField!
    @IBOutlet public private(set) weak var searchResultsTableView: UITableView!
    
    public var moviesLoader:LoadMovieUseCase?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        searchBar.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing)))
        
        searchResultsTableView.keyboardDismissMode = .onDrag

        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func search(with query:String) {
        moviesLoader?.load() { _ in }
    }
    
}

extension SearchMoviesViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !(textField.text ?? "").isEmpty {
            search(with: textField.text!)
        }
        
        return true
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
