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
    var insertionCompletions = [(Error?) -> Void]()
    
    func insert(_ movie:StoreMovieDTO, completion:@escaping insertionCompletion) {
        receivedMessages.append(.insert(movie))
        insertionCompletions.append(completion)
    }
    
    func retrieve() {
        receivedMessages.append(.retrieve)
    }
    
    func completeInsertion(with error:NSError, at index:Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index:Int = 0) {
        insertionCompletions[index](nil)
    }
}
