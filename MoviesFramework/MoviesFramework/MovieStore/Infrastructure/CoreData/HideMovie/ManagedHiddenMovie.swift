//
//  ManagedHiddenMovie.swift
//  MoviesFramework
//
//  Created by Mehtab on 07/01/2023.
//

import Foundation
import CoreData

@objc(ManagedHiddenMovie)
class ManagedHiddenMovie: NSManagedObject {
    @NSManaged var movie: ManagedMovie
}



extension ManagedHiddenMovie {
    
    var DTOFavourite: StoreMovieDTO {
        return StoreMovieDTO(id: movie.id, title: movie.title, description: movie.movieDescription, poster: movie.poster, rating: movie.rating)
    }
    
    static func managedMovie(from movie:StoreMovieDTO, in context: NSManagedObjectContext) -> ManagedMovie {
        let managedMovie = ManagedMovie(context: context)
        managedMovie.id = movie.id
        managedMovie.title = movie.title
        managedMovie.movieDescription = movie.description
        managedMovie.poster = movie.poster
        managedMovie.rating = movie.rating
        return managedMovie
    }
    
    static func find(in context: NSManagedObjectContext) throws -> [ManagedHiddenMovie] {
        let request = NSFetchRequest<ManagedHiddenMovie>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request)
    }
}
