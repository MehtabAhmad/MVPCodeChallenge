//
//  CoreDataHiddenMovieStoreTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 07/01/2023.
//

import XCTest
import MoviesFramework

final class CoreDataHiddenMovieStoreTests: XCTestCase {

    func test_retrieveHidden_deliversEmptyOnEmptyHiddens() {
        expect(makeSUT(), toRetrieve: .empty)
    }
    
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HiddenMoviesStore {
        let storeBundle = Bundle(for: CoreDataMoviesStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataMoviesStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: HiddenMoviesStore, toRetrieve expectedResult: RetrieveStoreMovieResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for movie retrieval")
        
        sut.retrieveHidden { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
                
            case let (.found(expected), .found(retrieved)):
                XCTAssertEqual(expected, retrieved, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
