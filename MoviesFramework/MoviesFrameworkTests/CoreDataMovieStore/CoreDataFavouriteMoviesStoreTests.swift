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
    
    func test_retrieveFavourite_deliversFavouriteMoviesOnNonEmptyFavourites() {
        
        let sut = makeSUT()
        let item1 = uniqueMovieItems().dto
        let item2 = uniqueMovieItems().dto
        let item3 = uniqueMovieItems().dto
        
        insert(item1, to: sut)
        insert(item2, to: sut)
        insert(item3, to: sut)
        
        expect(sut, toRetrieve: .found([item1,item2,item3]))
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FavouriteMoviesStore {
        let storeBundle = Bundle(for: CoreDataMoviesStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataMoviesStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: FavouriteMoviesStore, toRetrieve expectedResult: RetrieveStoreMovieResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for movie retrieval")
        
        sut.retrieveFavourite { retrievedResult in
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
    
    @discardableResult
    private func insert(_ movie: StoreMovieDTO, to sut: FavouriteMoviesStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insertFavourite(movie) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
}
