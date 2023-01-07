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
}

extension CoreDataMoviesStore:FavouriteMoviesStore {
    
    public func insertFavourite(_ movie: StoreMovieDTO, completion: @escaping favouriteInsertionCompletion) {
        let context = self.context
        context.perform {
            do {
                let managedFavourite = ManagedFavouriteMovie(context: context)
                let managedMovie = ManagedMovie(context: context)
                managedMovie.id = movie.id
                managedMovie.title = movie.title
                managedMovie.movieDescription = movie.description
                managedMovie.poster = movie.poster
                managedMovie.rating = movie.rating
                managedFavourite.movie = managedMovie
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieveFavourite(completion: @escaping favouriteRetrievalCompletion) {
        let context = self.context
        context.perform {
            do {
                let request = NSFetchRequest<ManagedFavouriteMovie>(entityName: ManagedFavouriteMovie.entity().name!)
                request.returnsObjectsAsFaults = false
                let favourites = try context.fetch(request)
                guard favourites.count > 0 else { return completion(.empty) }
                
                completion(.found(
                    favourites.map {
                        let movie = $0.movie
                        return StoreMovieDTO(id: movie.id, title: movie.title, description: movie.movieDescription, poster: movie.poster, rating: movie.rating)
                    }))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
}


extension CoreDataMoviesStore:HiddenMoviesStore {
    
    public func insertHidden(_ movie: StoreMovieDTO, completion: @escaping hiddenInsertionCompletion) {
        
    }
    
    public func retrieveHidden(completion: @escaping hiddenRetrievalCompletion) {
        
    }
}

@objc(ManagedFavouriteMovie)
private class ManagedFavouriteMovie: NSManagedObject {
    @NSManaged var movie: ManagedMovie
}

@objc(ManagedHiddenMovie)
private class ManagedHiddenMovie: NSManagedObject {
    @NSManaged var movie: ManagedMovie
}

@objc(ManagedMovie)
private class ManagedMovie: NSManagedObject {
    @NSManaged var id: Int
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
