//
//  Equatable+DomainMovieToDTOMovieHelper.swift
//  MoviesFramework
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation

extension Equatable where Self == DomainMovie {
    func toDTOMovie() -> StoreMovieDTO {
        return StoreMovieDTO(id: self.id, title: self.title, description: self.description, poster: self.poster, rating: self.rating)
    }
}
