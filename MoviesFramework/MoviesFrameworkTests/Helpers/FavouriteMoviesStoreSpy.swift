//
//  MovieStoreSpy.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation
import MoviesFramework

final class FavouriteMoviesStoreSpy: FavouriteMoviesStore {
    
    enum Messages: Equatable {
        case insertFavourite(StoreMovieDTO)
        case retrieveFavourite
    }
    
    var receivedMessages = [Messages]()
    var favouriteInsertionCompletions = [favouriteInsertionCompletion]()
    var favouriteRetrievalCompletions = [favouriteRetrievalCompletion]()
    
    func insertFavourite(_ movie:StoreMovieDTO, completion:@escaping favouriteInsertionCompletion) {
        receivedMessages.append(.insertFavourite(movie))
        favouriteInsertionCompletions.append(completion)
    }
    
    func retrieveFavourite(completion: @escaping favouriteRetrievalCompletion) {
        receivedMessages.append(.retrieveFavourite)
        favouriteRetrievalCompletions.append(completion)
    }
    
    func completeFavouriteInsertion(with error:NSError, at index:Int = 0) {
        favouriteInsertionCompletions[index](error)
    }
    
    func completeFavouriteInsertionSuccessfully(at index:Int = 0) {
        favouriteInsertionCompletions[index](nil)
    }
    
    func completeFavouriteRetrival(with error:NSError, at index:Int = 0) {
        favouriteRetrievalCompletions[index](.failure(error))
    }
    
    func completeFavouriteRetrivalWithEmptyList(at index:Int = 0) {
        favouriteRetrievalCompletions[index](.empty)
    }
    
    func completeFavouriteRetrival(with movies:[StoreMovieDTO], at index:Int = 0) {
        favouriteRetrievalCompletions[index](.found(movies))
    }
}
