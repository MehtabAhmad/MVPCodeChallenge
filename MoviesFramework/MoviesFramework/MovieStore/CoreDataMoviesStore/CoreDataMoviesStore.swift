//
//  CoreDataMoviesStore.swift
//  MoviesFramework
//
//  Created by Mehtab on 05/01/2023.
//

import Foundation

public final class CoreDataMoviesStore: FavouriteMoviesStore {
    
    public init() {}
    
    public func insertFavourite(_ movie: StoreMovieDTO, completion: @escaping favouriteInsertionCompletion) {
        
    }
    
    public func retrieveFavourite(completion: @escaping favouriteRetrievalCompletion) {
        completion(.empty)
    }
}


extension CoreDataMoviesStore:HiddenMoviesStore {
    
    public func insertHidden(_ movie: StoreMovieDTO, completion: @escaping hiddenInsertionCompletion) {
        
    }
    
    public func retrieveHidden(completion: @escaping hiddenRetrievalCompletion) {
        
    }
}
