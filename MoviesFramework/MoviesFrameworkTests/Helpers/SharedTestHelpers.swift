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
