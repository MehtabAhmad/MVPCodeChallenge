//
//  LoadMovieUseCase.swift
//  MoviesFramework
//
//  Created by Mehtab on 01/01/2023.
//

import Foundation

public enum LoadMovieResult {
    case success([DomainMovie])
    case failure(Error)
}

public protocol LoadMovieUseCase {
    func load(completion: @escaping (LoadMovieResult) -> Void)
}
