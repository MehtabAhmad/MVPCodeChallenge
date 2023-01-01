//
//  DomainMovie.swift
//  MoviesFramework
//
//  Created by Mehtab on 01/01/2023.
//

import Foundation

public struct DomainMovie: Equatable {
    let id:UUID
    let title:String
    let description:String
    let poster:URL
    let rating:Float
}
