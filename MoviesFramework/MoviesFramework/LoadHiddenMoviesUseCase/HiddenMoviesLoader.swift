//
//  HiddenMoviesLoader.swift
//  MoviesFramework
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation

public final class HiddenMoviesLoader:LoadMovieUseCase {
    
    let store:HiddenMoviesStore
    
    public init(store: HiddenMoviesStore) {
        self.store = store
    }
    
    public func load(completion:@escaping (LoadMovieResult) -> Void) {
        store.retrieveHidden() { [weak self] result in
            guard self != nil else {return}
            switch result {
            case .empty:
                completion(.success([]))
            case let .found(DTOMovies):
                completion(.success(DTOMovies.toDomainMovies()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

private extension Array where Element == StoreMovieDTO {
    func toDomainMovies() -> [DomainMovie] {
        return map {
            DomainMovie(id: $0.id, title: $0.title, description: $0.description, poster: $0.poster, rating: $0.rating)
        }
    }
}
