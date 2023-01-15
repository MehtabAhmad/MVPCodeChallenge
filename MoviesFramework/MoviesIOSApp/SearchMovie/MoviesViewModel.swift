//
//  MoviesViewModel.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 15/01/2023.
//

import MoviesFramework

final class MoviesViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let moviesLoader: LoadMovieUseCase
    
    init(moviesLoader: LoadMovieUseCase) {
        self.moviesLoader = moviesLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onMoviesLoad: Observer<[DomainMovie]>?
    
    func loadMovie() {
        onLoadingStateChange?(true)
        moviesLoader.load { [weak self] result in
            switch result {
            case let .success(movies):
                self?.onMoviesLoad?(movies)
            default: break
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
