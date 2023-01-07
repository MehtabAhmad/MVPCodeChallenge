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
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "MovieStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
            let context = self.context
            context.perform { action(context) }
        }
}

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

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url:URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
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
