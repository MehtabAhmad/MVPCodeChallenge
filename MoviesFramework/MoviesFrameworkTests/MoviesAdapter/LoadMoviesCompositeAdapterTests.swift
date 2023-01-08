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
                        let filtered = Array(Set(remoteMovies).subtracting(Set(hiddenMovies)))
                        completion(.success(filtered))
                    default:
                        completion(.success(remoteMovies))
                    }
                }
            case .failure:break
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
        
        let item1 = uniqueMovieItems()
        let item2 = uniqueMovieItems()
        let item3 = uniqueMovieItems()
        let item4 = uniqueMovieItems()
        
        let remoteMovies = [item1.model, item2.model, item3.model,item4.model]
        
        let hiddenMovies = [item1.model,item4.model]
        let favouriteMovies = [DomainMovie]()
        
        let filteredMovies = [item2.model, item3.model]

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
    
    func test_load_deliversEmptyArrayWhenRemoteResultIsEmptyButHiddenMoviesAdded() {
        
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
    
    func test_load_deliversRemoteMoviesOnMissmatchingRemoteAndHiddenMovies() {
        
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
