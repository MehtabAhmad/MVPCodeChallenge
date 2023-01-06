//
//  CoreDataMoviesStore.swift
//  MoviesFramework
//
//  Created by Mehtab on 05/01/2023.
//

import Foundation
import CoreData

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

private class ManagedFavouriteMovie: NSManagedObject {
    @NSManaged var movie: NSOrderedSet
}

private class ManagedHiddenMovie: NSManagedObject {
    @NSManaged var movie: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var movieDescription: String
    @NSManaged var title: String
    @NSManaged var poster: URL
    @NSManaged var rating: Float
    @NSManaged var favourite: ManagedFavouriteMovie
    @NSManaged var hidden: ManagedHiddenMovie
}
