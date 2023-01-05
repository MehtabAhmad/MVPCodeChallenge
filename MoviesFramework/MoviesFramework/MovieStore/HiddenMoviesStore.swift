//
//  HiddenMoviesStore.swift
//  MoviesFramework
//
//  Created by Mehtab on 05/01/2023.
//

import Foundation

public protocol HiddenMoviesStore {
    
    typealias hiddenInsertionCompletion = (Error?) -> Void
    
    typealias hiddenRetrievalCompletion = (RetrieveStoreMovieResult) -> Void
    
    func insertHidden(_ movie:StoreMovieDTO, completion:@escaping hiddenInsertionCompletion)
    
    func retrieveHidden(completion:@escaping hiddenRetrievalCompletion)
}
