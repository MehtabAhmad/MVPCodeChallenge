//
//  HideMovieFromSearchUseCaseTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 04/01/2023.
//

import XCTest
import MoviesFramework

class HideMovieFromSearchUseCaseHandler {
    let store:MovieStore
    
    public init(store:MovieStore) {
        self.store = store
    }
    
}

final class HideMovieFromSearchUseCaseTests: XCTestCase {

    func test_init_doesnotMessageStore() {
        let (_,store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    
    // MARK: - Helper
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut:HideMovieFromSearchUseCaseHandler, store:MovieStoreSpy) {
        let store = MovieStoreSpy()
        let sut = HideMovieFromSearchUseCaseHandler(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut,store)
    }
    
    
    private class MovieStoreSpy: MovieStore {
        
        enum Messages: Equatable {
            case insert(DomainMovie)
        }
        
        var receivedMessages = [Messages]()
        var insertionCompletions = [(Error?) -> Void]()
        
        func insert(_ movie:DomainMovie, completion:@escaping insertionCompletion) {
            receivedMessages.append(.insert(movie))
            insertionCompletions.append(completion)
        }
        
        func completeInsertion(with error:NSError, at index:Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(at index:Int = 0) {
            insertionCompletions[index](nil)
        }
    }

}
