//
//  AddFavouriteMovieUseCase.swift
//  MoviesFramework
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation

public protocol AddFavouriteMovieUseCase {
    typealias addFavouriteResult = Error?
    func addFavourite(_ movie:DomainMovie, completion:@escaping (addFavouriteResult) -> Void)
}
