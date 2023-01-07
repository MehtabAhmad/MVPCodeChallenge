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
}
