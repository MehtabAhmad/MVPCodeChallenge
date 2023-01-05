//
//  MovieStore.swift
//  MoviesFramework
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation

public enum RetrieveFavouriteMovieResult {
    case empty
    case found([StoreMovieDTO])
    case failure(Error)
}

public protocol MovieStore {
    typealias insertionCompletion = (Error?) -> Void
    typealias retrivalCompletion = (RetrieveFavouriteMovieResult) -> Void
    
    func insert(_ movie:StoreMovieDTO, completion:@escaping insertionCompletion)
    func retrieve(completion:@escaping retrivalCompletion)
}
