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
