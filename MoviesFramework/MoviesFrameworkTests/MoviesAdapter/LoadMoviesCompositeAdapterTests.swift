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
    
    init(remoteLoader:LoadMovieUseCase, favouriteLoader:LoadMovieUseCase, hiddenLoader:LoadMovieUseCase) {
        self.remoteLoader = remoteLoader
        self.favouriteLoader = favouriteLoader
        self.hiddenLoader = hiddenLoader
    }
    
    func load(completion: @escaping (MoviesFramework.LoadMovieResult) -> Void) {
        remoteLoader.load() { [unowned self] remoteResult in
            switch remoteResult {
            case let .success(remoteMovies):
                self.hiddenLoader.load() { hiddenResult in
                    switch hiddenResult {
                    case let .success(hiddenMovies) where hiddenMovies.count > 0:
                        let hiddenSet = Set(hiddenMovies)
                        let filtered = remoteMovies.filter { !hiddenSet.contains($0) }
                        completion(.success(filtered))
                    default:
                        completion(.success(remoteMovies))
                    }
                }
            case .failure:
                completion(remoteResult)
            }
        }
    }
}

final class LoadMoviesCompositeAdapterTests: XCTestCase {
    
    func test_load_deliversRemoteMoviesOnRemoteSuccessWhenNoFavouritesAndNoHidden() {
        let remoteMovies = uniqueMovieItemArray().model
        let favouriteMovies = [DomainMovie]()
        let hiddenMovies = [DomainMovie]()
        
        let remoteLoader = LoaderStub(result: .success(remoteMovies))
        let favouriteLoader = LoaderStub(result: .success(favouriteMovies))
        let hiddenLoader = LoaderStub(result: .success(hiddenMovies))
        
        let sut = LoadMoviesCompositeAdapter(remoteLoader: remoteLoader, favouriteLoader: favouriteLoader, hiddenLoader: hiddenLoader)
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
        
        let remoteMovies = [item1, item2, item3, item4]
        
        let hiddenMovies = [item1,item4]
        
        let favouriteMovies = [DomainMovie]()
        
        let filteredMovies = [item2, item3]

        let remoteLoader = LoaderStub(result: .success(remoteMovies))
        let favouriteLoader = LoaderStub(result: .success(favouriteMovies))
        let hiddenLoader = LoaderStub(result: .success(hiddenMovies))

        let sut = LoadMoviesCompositeAdapter(remoteLoader: remoteLoader, favouriteLoader: favouriteLoader, hiddenLoader: hiddenLoader)
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
        
        let remoteMovies = [DomainMovie]()
        let hiddenMovies = uniqueMovieItemArray().model
        let favouriteMovies = [DomainMovie]()
        
        let remoteLoader = LoaderStub(result: .success(remoteMovies))
        let favouriteLoader = LoaderStub(result: .success(favouriteMovies))
        let hiddenLoader = LoaderStub(result: .success(hiddenMovies))

        let sut = LoadMoviesCompositeAdapter(remoteLoader: remoteLoader, favouriteLoader: favouriteLoader, hiddenLoader: hiddenLoader)
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
    
    func test_load_doesnotExcludeRemoteMoviesOnMissmatchingRemoteAndHiddenMovies() {
        
        let remoteMovies = uniqueMovieItemArray().model
        let hiddenMovies = uniqueMovieItemArray().model
        let favouriteMovies = [DomainMovie]()
        
        let remoteLoader = LoaderStub(result: .success(remoteMovies))
        let favouriteLoader = LoaderStub(result: .success(favouriteMovies))
        let hiddenLoader = LoaderStub(result: .success(hiddenMovies))

        let sut = LoadMoviesCompositeAdapter(remoteLoader: remoteLoader, favouriteLoader: favouriteLoader, hiddenLoader: hiddenLoader)
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
        let remoteLoader = LoaderStub(result: .failure(remoteError))
        let favouriteLoader = LoaderStub(result: .success([]))
        let hiddenLoader = LoaderStub(result: .success([]))

        let sut = LoadMoviesCompositeAdapter(remoteLoader: remoteLoader, favouriteLoader: favouriteLoader, hiddenLoader: hiddenLoader)
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
