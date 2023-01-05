//
//  HiddenMoviesStoreSpy.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 05/01/2023.
//

import Foundation
import MoviesFramework

class HiddenMovieStoreSpy:HiddenMoviesStore {
    
    enum Messages: Equatable {
        case insertHidden(StoreMovieDTO)
        case retrieveHidden
    }
    
    var receivedMessages = [Messages]()
    var hiddenInsertionCompletions = [hiddenInsertionCompletion]()
    var hiddenRetrievalCompletions = [hiddenRetrievalCompletion]()
    
    func insertHidden(_ movie:StoreMovieDTO, completion:@escaping hiddenInsertionCompletion) {
        receivedMessages.append(.insertHidden(movie))
        hiddenInsertionCompletions.append(completion)
    }
    
    func retrieveHidden(completion: @escaping hiddenRetrievalCompletion) {
        receivedMessages.append(.retrieveHidden)
        hiddenRetrievalCompletions.append(completion)
    }
    
    func completeHiddenInsertion(with error:NSError, at index:Int = 0) {
        hiddenInsertionCompletions[index](error)
    }
    
    func completeHiddenInsertionSuccessfully(at index:Int = 0) {
        hiddenInsertionCompletions[index](nil)
    }
    
    func completeHiddenRetrival(with error:NSError, at index:Int = 0) {
        hiddenRetrievalCompletions[index](.failure(error))
    }
    
    func completeHiddenRetrivalWithEmptyList(at index:Int = 0) {
        hiddenRetrievalCompletions[index](.empty)
    }
    
    func completeHiddenRetrival(with movies:[StoreMovieDTO], at index:Int = 0) {
        hiddenRetrievalCompletions[index](.found(movies))
    }
}
