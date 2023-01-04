//
//  MovieStoreSpy.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 04/01/2023.
//

import Foundation
import MoviesFramework

final class MovieStoreSpy: MovieStore {
    
    enum Messages: Equatable {
        case insert(StoreMovieDTO)
        case retrieve
    }
    
    var receivedMessages = [Messages]()
    
    var insertionCompletions = [insertionCompletion]()
    var retrievalCompletions = [retrivalCompletion]()
    
    func insert(_ movie:StoreMovieDTO, completion:@escaping insertionCompletion) {
        receivedMessages.append(.insert(movie))
        insertionCompletions.append(completion)
    }
    
    func retrieve(completion: @escaping retrivalCompletion) {
        receivedMessages.append(.retrieve)
        retrievalCompletions.append(completion)
    }
    
    func completeInsertion(with error:NSError, at index:Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index:Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func completeRetrival(with error:NSError, at index:Int = 0) {
        retrievalCompletions[index](error)
    }
}
