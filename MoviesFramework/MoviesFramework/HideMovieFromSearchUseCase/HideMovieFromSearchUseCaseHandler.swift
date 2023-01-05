//
//  HideMovieFromSearchUseCaseHandler.swift
//  MoviesFramework
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation

public final class HideMovieFromSearchUseCaseHandler: HideMovieFromSearchUseCase {
    
    let store:HiddenMoviesStore
    
    public init(store:HiddenMoviesStore) {
        self.store = store
    }
    
    public func hide(_ movie:DomainMovie, completion:@escaping (hideMovieResult) -> Void) {
        store.insertHidden(movie.toDTOMovie()) { [weak self] error in
            guard self != nil else {return}
            completion(error)
        }
    }
}
