//
//  CoreDataMovieStore+FavouriteMovieStore.swift
//  MoviesFramework
//
//  Created by Mehtab on 07/01/2023.
//

import Foundation

extension CoreDataMoviesStore:FavouriteMoviesStore {
    
    public func insertFavourite(_ movie: StoreMovieDTO, completion: @escaping favouriteInsertionCompletion) {
        perform { context in
            do {
                let managedFavourite = ManagedFavouriteMovie(context: context)
                managedFavourite.movie = ManagedFavouriteMovie.managedMovie(from: movie, in: context)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieveFavourite(completion: @escaping favouriteRetrievalCompletion) {
        perform { context in
            do {
                let favourites = try ManagedFavouriteMovie.find(in: context)
                guard favourites.count > 0 else { return completion(.empty) }
                completion(.found( favourites.map { $0.DTOFavourite }))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
