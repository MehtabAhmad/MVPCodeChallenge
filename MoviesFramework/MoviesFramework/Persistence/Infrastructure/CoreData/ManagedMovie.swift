//
//  ManagedMovie.swift
//  MoviesFramework
//
//  Created by Mehtab on 07/01/2023.
//

import Foundation
import CoreData

@objc(ManagedMovie)
class ManagedMovie: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var movieDescription: String
    @NSManaged var title: String
    @NSManaged var poster: URL?
    @NSManaged var rating: Float
    @NSManaged var favourite: ManagedFavouriteMovie
    @NSManaged var hidden: ManagedHiddenMovie
}
