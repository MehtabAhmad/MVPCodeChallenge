//
//  LoadMoviesCompositeAdapter.swift
//  MoviesFramework
//
//  Created by Mehtab on 08/01/2023.
//

import Foundation

public final class LoadMoviesCompositeAdapter:LoadMovieUseCase {
    
    private let remoteLoader:LoadMovieUseCase
    private let favouriteLoader:LoadMovieUseCase
    private let hiddenLoader:LoadMovieUseCase
    
    public typealias Result = MoviesFramework.LoadMovieResult
    
    public init(remoteLoader:LoadMovieUseCase, favouriteLoader:LoadMovieUseCase, hiddenLoader:LoadMovieUseCase) {
        self.remoteLoader = remoteLoader
        self.favouriteLoader = favouriteLoader
        self.hiddenLoader = hiddenLoader
    }
    
    public func load(completion: @escaping (Result) -> Void) {
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
