//
//  MovieRefreshController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 14/01/2023.
//

import Foundation
import UIKit

final class MovieRefreshController {
    private(set) lazy var view = binded(UIRefreshControl())
    
    private let moviesViewModel: MoviesViewModel
    
    var isRefreshing:Bool {
        return view.isRefreshing
    }
    
    init(moviesViewModel: MoviesViewModel) {
        self.moviesViewModel = moviesViewModel
    }
    
    @objc func refresh() {
        moviesViewModel.loadMovie()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        moviesViewModel.onLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.beginRefreshing()
            } else {
                self?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    func beginRefreshing() {
        view.beginRefreshing()
    }
    
    func endRefreshing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak view] in
            view?.endRefreshing()
        }
    }
}
