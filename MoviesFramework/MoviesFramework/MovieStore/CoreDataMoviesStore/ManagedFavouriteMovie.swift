//
//  ManagedFavouriteMovie.swift
//  MoviesFramework
//
//  Created by Mehtab on 07/01/2023.
//

import Foundation
import CoreData

@objc(ManagedFavouriteMovie)
class ManagedFavouriteMovie: NSManagedObject {
    @NSManaged var movie: ManagedMovie
    
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
}
