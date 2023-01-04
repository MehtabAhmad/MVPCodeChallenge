//
//  SharedTestHelpers.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation
import MoviesFramework

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func uniqueMovieItem() -> DomainMovie {
    DomainMovie(
        id: UUID().hashValue,
        title: "a title",
        description: "a description",
        poster: URL(string: "http://a-url.com")!,
        rating: 3.5)
}

func uniqueMovieItems() -> (model: DomainMovie, dto: StoreMovieDTO) {
    let model = uniqueMovieItem()
    let dto = StoreMovieDTO(
        id: model.id,
        title: model.title,
        description: model.description,
        poster: model.poster,
        rating: model.rating)
    
    return (model, dto)
}

func uniqueMovieItemArray() -> (model: [DomainMovie], dto: [StoreMovieDTO]) {
    let model = [uniqueMovieItem(),uniqueMovieItem()]
    let dto = model.map {
        StoreMovieDTO(
            id: $0.id,
            title: $0.title,
            description: $0.description,
            poster: $0.poster,
            rating: $0.rating)
    }
    return (model, dto)
}
