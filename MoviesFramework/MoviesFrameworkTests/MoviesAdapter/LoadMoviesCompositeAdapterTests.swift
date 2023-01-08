//
//  RemoteWithLocalFavouriteMoviesAdapterTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 07/01/2023.
//

import XCTest
import MoviesFramework

class LoadMoviesCompositeAdapter:LoadMovieUseCase {
    
    let remoteLoader:LoadMovieUseCase
    let favouriteLoader:LoadMovieUseCase
    let hiddenLoader:LoadMovieUseCase
    
    typealias Result = MoviesFramework.LoadMovieResult
    
    init(remoteLoader:LoadMovieUseCase, favouriteLoader:LoadMovieUseCase, hiddenLoader:LoadMovieUseCase) {
        self.remoteLoader = remoteLoader
        self.favouriteLoader = favouriteLoader
        self.hiddenLoader = hiddenLoader
    }
    
    func load(completion: @escaping (Result) -> Void) {
        remoteLoader.load() { [weak self] remoteResult in
            guard let self = self else { return }
            switch remoteResult {
            case let .success(remoteMovies):
                self.filter(remoteMovies, completion: completion)
            case .failure:
                completion(remoteResult)
            }
        }
    }
    
    private func filter(_ remoteMovies:[DomainMovie], completion: @escaping (Result) -> Void) {
        hiddenLoader.load() { [weak self] hiddenResult in
            guard let self = self else { return }
            switch hiddenResult {
            case let .success(hiddenMovies) where hiddenMovies.count > 0:
                self.checkFavourites(for: self.remove(hiddenMovies, from: remoteMovies), completion: completion)
            default:
                self.checkFavourites(for: remoteMovies, completion: completion)
            }
        }
    }
    
    private func remove(_ hiddenMovies:[DomainMovie], from remoteMovies:[DomainMovie]) -> [DomainMovie] {
        let hiddenSet = Set(hiddenMovies)
        return remoteMovies.filter { !hiddenSet.contains($0) }
    }
    
    private func checkFavourites(for remoteMovies:[DomainMovie], completion: @escaping (Result) -> Void) {
        favouriteLoader.load() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(favourites) where favourites.count > 0:
                self.merge(favourites, with: remoteMovies, completion: completion)
            default:
                completion(.success(remoteMovies))
            }
        }
    }
    
    private func merge(_ favouriteMovies:[DomainMovie], with remoteMovies: [DomainMovie], completion: @escaping (Result) -> Void) {
        
        var mutableRemotes = remoteMovies
        
        for i in 0..<remoteMovies.count {
            if favouriteMovies.contains(remoteMovies[i]) {
                mutableRemotes[i].isFavourite = true
            }
        }
        completion(.success(mutableRemotes))
    }
}

final class LoadMoviesCompositeAdapterTests: XCTestCase {
    
    func test_load_deliversRemoteMoviesOnRemoteSuccessWhenNoFavouritesAndNoHidden() {
        let remoteMovies = uniqueMovieItemArray().model
        
        let sut = makeSUT(remoteResult: .success(remoteMovies), favouriteResult: .success([]), hiddenResult: .success([]))
        
        let exp = expectation(description: "wait for load completion")
        sut.load() { result in
            switch result {
            case let .success(receivedMovies):
                XCTAssertEqual(receivedMovies, remoteMovies)
            default:
                XCTFail("Expected successfull movies result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_excludesHiddenFromRemoteMoviesWhenHiddenAdded() {
        
        let item1 = uniqueMovieItem()
        let item2 = uniqueMovieItem()
        let item3 = uniqueMovieItem()
        let item4 = uniqueMovieItem()
        
        let filteredMovies = [item2, item3]
        
        let sut = makeSUT(remoteResult: .success([item1, item2, item3, item4]), favouriteResult: .success([]), hiddenResult: .success([item1,item4]))
        
        let exp = expectation(description: "wait for load completion")
        sut.load() { result in
            switch result {
            case let .success(receivedMovies):
                XCTAssertEqual(receivedMovies, filteredMovies)
            default:
                XCTFail("Expected successfull movies result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversEmptyOnEmptyRemoteResultOnNonEmptyHiddenMoviesA() {
        
        let sut = makeSUT(remoteResult: .success([]), favouriteResult: .success([]), hiddenResult: .success(uniqueMovieItemArray().model))
        
        let exp = expectation(description: "wait for load completion")
        sut.load() { result in
            switch result {
            case let .success(receivedMovies):
                XCTAssertEqual(receivedMovies, [])
            default:
                XCTFail("Expected successfull movies result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_doesnotExcludeRemoteMoviesOnMissmatchingRemoteAndHiddenMovies() {
        
        let remoteMovies = uniqueMovieItemArray().model
        
        let sut = makeSUT(remoteResult: .success(remoteMovies), favouriteResult: .success([]), hiddenResult: .success(uniqueMovieItemArray().model))
        
        let exp = expectation(description: "wait for load completion")
        sut.load() { result in
            switch result {
            case let .success(receivedMovies):
                XCTAssertEqual(receivedMovies, remoteMovies)
            default:
                XCTFail("Expected successfull movies result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversErrorOnRemoteFailure() {
        
        let remoteError = anyNSError()
        
        let sut = makeSUT(remoteResult: .failure(remoteError), favouriteResult: .success([]), hiddenResult: .success([]))
        
        let exp = expectation(description: "wait for load completion")
        sut.load() { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as NSError?, remoteError)
            default:
                XCTFail("Expected failure result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversRemoteAsFavouritesWhenMatchingFavouritsExists() {
        
        let item1 = uniqueMovieItems()
        let item2 = uniqueMovieItems()
        let item3 = uniqueMovieItems()
        let item4 = uniqueMovieItems()
        
        let sut = makeSUT(remoteResult: .success([item1.model,item2.model,item3.model,item4.model]), favouriteResult: .success([item2.model,item4.model]), hiddenResult: .success(uniqueMovieItemArray().model))
        
        let expectedMovies = [item1.model,item2.favourite,item3.model,item4.favourite]
        
        let exp = expectation(description: "wait for load completion")
        sut.load() { result in
            switch result {
            case let .success(receivedMovies):
                XCTAssertEqual(receivedMovies, expectedMovies)
            default:
                XCTFail("Expected successfull movies result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversNoRemoteAsFavouriteWhenNoMatchingFavouritExists() {
        
        let movie1 = uniqueMovieItem()
        let movie2 = uniqueMovieItem()
        let movie3 = uniqueMovieItem()
        let movie4 = uniqueMovieItem()
        let movie5 = uniqueMovieItem()
        
        let remoteMovies = [movie1,movie2,movie3]
        let favouriteMovies = [movie4,movie5]
        
        let sut = makeSUT(remoteResult:.success(remoteMovies), favouriteResult: .success(favouriteMovies), hiddenResult: .success(uniqueMovieItemArray().model))
                
        let exp = expectation(description: "wait for load completion")
        sut.load() { result in
            switch result {
            case let .success(receivedMovies):
                XCTAssertEqual(receivedMovies, remoteMovies)
            default:
                XCTFail("Expected successfull movies result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(remoteResult: LoadMoviesCompositeAdapter.Result, favouriteResult: LoadMoviesCompositeAdapter.Result, hiddenResult: LoadMoviesCompositeAdapter.Result, file: StaticString = #filePath, line: UInt = #line) -> LoadMovieUseCase {
        
        let remoteLoader = LoaderStub(result: remoteResult)
        let favouriteLoader = LoaderStub(result: favouriteResult)
        let hiddenLoader = LoaderStub(result: hiddenResult)
        
        let sut = LoadMoviesCompositeAdapter(remoteLoader: remoteLoader, favouriteLoader: favouriteLoader, hiddenLoader: hiddenLoader)
        trackForMemoryLeaks(remoteLoader, file: file, line: line)
        trackForMemoryLeaks(favouriteLoader, file: file, line: line)
        trackForMemoryLeaks(hiddenLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class LoaderStub:LoadMovieUseCase {
        private let result:MoviesFramework.LoadMovieResult
        
        init(result: MoviesFramework.LoadMovieResult) {
            self.result = result
        }
        
        func load(completion: @escaping (MoviesFramework.LoadMovieResult) -> Void) {
            completion(result)
        }
    }
}
