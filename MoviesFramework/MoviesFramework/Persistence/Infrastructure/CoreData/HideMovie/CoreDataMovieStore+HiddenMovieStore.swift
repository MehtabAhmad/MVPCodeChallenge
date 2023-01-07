//
//  CoreDataMovieStore+HiddenMovieStore.swift
//  MoviesFramework
//
//  Created by Mehtab on 07/01/2023.
//

import Foundation

extension CoreDataMoviesStore:HiddenMoviesStore {
    
    public func insertHidden(_ movie: StoreMovieDTO, completion: @escaping hiddenInsertionCompletion) {
        perform { context in
            do {
                let managedHidden = ManagedHiddenMovie(context: context)
                managedHidden.movie = ManagedHiddenMovie.managedMovie(from: movie, in: context)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieveHidden(completion: @escaping hiddenRetrievalCompletion) {
        perform { context in
            do {
                let hiddens = try ManagedHiddenMovie.find(in: context)
                guard hiddens.count > 0 else { return completion(.empty) }
                completion(.found( hiddens.map { $0.DTOFavourite }))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
