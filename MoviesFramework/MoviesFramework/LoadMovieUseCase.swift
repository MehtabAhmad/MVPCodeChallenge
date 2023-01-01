//
//  LoadMovieUseCase.swift
//  MoviesFramework
//
//  Created by Mehtab on 01/01/2023.
//

import Foundation

enum LoadMovieResult {
    case success([DomainMovie])
    case error(Error)
}

protocol LoadMovieUseCase {
    func load(completion: @escaping (LoadMovieResult) -> Void)
}
