//
//  MovieStore.swift
//  MoviesFramework
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation

public protocol MovieStore {
    typealias insertionCompletion = (Error?) -> Void
    func insert(_ movie:DomainMovie, completion:@escaping insertionCompletion)
}
