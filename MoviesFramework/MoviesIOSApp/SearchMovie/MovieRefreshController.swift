//
//  MovieRefreshController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 14/01/2023.
//

import Foundation
import MoviesFramework
import UIKit

final class MovieRefreshController {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let loadMovieHandler: LoadMovieUseCase
    
    var isRefreshing:Bool {
        return view.isRefreshing
    }
    
    init(loader: LoadMovieUseCase) {
        loadMovieHandler = loader
    }

    var onRefresh: (([DomainMovie]) -> Void)?
    
    @objc func refresh() {
        beginRefreshing()
        loadMovieHandler.load { [weak self] result in
            switch(result) {
            case let .success(movies):
                self?.onRefresh?(movies)
            default: break
            }
            self?.endRefreshing()
        }
    }
    
    func beginRefreshing() {
        view.beginRefreshing()
    }
    
    func endRefreshing() {
        view.endRefreshing()
    }
}
