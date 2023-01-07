//
//  MovieStore.swift
//  MoviesFramework
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation

public enum RetrieveStoreMovieResult {
    case empty
    case found([StoreMovieDTO])
    case failure(Error)
}

public protocol FavouriteMoviesStore {

    typealias favouriteInsertionCompletion = (Error?) -> Void
    
    typealias favouriteRetrievalCompletion = (RetrieveStoreMovieResult) -> Void
    
    func insertFavourite(_ movie:StoreMovieDTO, completion:@escaping favouriteInsertionCompletion)
    
    func retrieveFavourite(completion:@escaping favouriteRetrievalCompletion)
}
