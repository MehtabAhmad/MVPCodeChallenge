//
//  AddFavouriteMovieUseCaseHandler.swift
//  MoviesFramework
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation

public final class AddFavouriteMovieUseCaseHandler {
    
    let store:MovieStore
    
    public typealias addFavouriteResult = Error?
    
    public init(store:MovieStore) {
        self.store = store
    }
    
    public func addFavourite(_ movie:DomainMovie, completion:@escaping (addFavouriteResult) -> Void) {
        store.insert(movie) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}
