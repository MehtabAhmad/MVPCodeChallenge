//
//  AddFavouriteMovieUseCaseHandler.swift
//  MoviesFramework
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation

public final class AddFavouriteMovieUseCaseHandler: AddFavouriteMovieUseCase {
    
    private let store:FavouriteMoviesStore
    private let dataAlreadyExistsError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "This movie already existis in favourites"])
    
    public init(store:FavouriteMoviesStore) {
        self.store = store
    }
    
    public func addFavourite(_ movie:DomainMovie, completion:@escaping (addFavouriteResult) -> Void) {
        store.retrieveFavourite() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .found(existingFavourites) where existingFavourites.contains(movie.toDTOMovie()):
                completion(self.dataAlreadyExistsError)
            case let .failure(error):
                completion(error)
            default:
                self.insert(movie.toDTOMovie(), completion: completion)
            }
        }
    }
    
    private func insert(_ movie:StoreMovieDTO, completion:@escaping (addFavouriteResult) -> Void) {
        store.insertFavourite(movie) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}
