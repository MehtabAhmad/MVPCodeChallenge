//
//  CoreDataMovieStoreTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 05/01/2023.
//


import XCTest
import MoviesFramework

final class CoreDataFavouriteMoviesStoreTests: XCTestCase {
    
    func test_retrieveFavourite_deliversEmptyOnEmptyFavourites() {
        expect(makeSUT(), toRetrieve: .empty)
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FavouriteMoviesStore {
        let storeBundle = Bundle(for: CoreDataMoviesStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataMoviesStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func expect(_ sut: FavouriteMoviesStore, toRetrieve expectedResult: RetrieveStoreMovieResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for movie retrieval")
        
        sut.retrieveFavourite { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
                
            case let (.found(expected), .found(retrieved)):
                XCTAssertEqual(retrieved, expected, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
