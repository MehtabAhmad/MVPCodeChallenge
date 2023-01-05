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

public protocol MovieStore {
    typealias insertionCompletion = (Error?) -> Void
    typealias retrivalCompletion = (RetrieveStoreMovieResult) -> Void
    
    func insertFavourite(_ movie:StoreMovieDTO, completion:@escaping insertionCompletion)
    func insertHidden(_ movie:StoreMovieDTO, completion:@escaping insertionCompletion)
    func retrieveFavourite(completion:@escaping retrivalCompletion)
    func retrieveHidden(completion:@escaping retrivalCompletion)
}
