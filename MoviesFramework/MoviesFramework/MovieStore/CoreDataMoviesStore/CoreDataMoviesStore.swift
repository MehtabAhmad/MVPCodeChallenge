//
//  CoreDataMoviesStore.swift
//  MoviesFramework
//
//  Created by Mehtab on 05/01/2023.
//

import Foundation
import CoreData

public final class CoreDataMoviesStore {
    
    private let container: NSPersistentContainer
    
    public init(bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "MovieStore", in: bundle)
    }
}

extension CoreDataMoviesStore:FavouriteMoviesStore {
    
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

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
