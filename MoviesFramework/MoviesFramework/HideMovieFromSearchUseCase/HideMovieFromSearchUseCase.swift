//
//  HideMovieFromSearchUseCase.swift
//  MoviesFramework
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation

public protocol HideMovieFromSearchUseCase {
    typealias hideMovieResult = Error?
    func hide(_ movie:DomainMovie, completion:@escaping (hideMovieResult) -> Void)
}
