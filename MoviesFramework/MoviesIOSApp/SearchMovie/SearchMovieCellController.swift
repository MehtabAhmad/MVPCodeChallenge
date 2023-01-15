//
//  SearchMovieCellController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 14/01/2023.
//

import Foundation
import MoviesFramework
import UIKit



final class SearchMovieCellController {
    typealias Observer<T> = (T) -> Void
    
    var model: DomainMovie
    private let imageLoader: ImageDataLoader
    private var task: ImageDataLoaderTask?
    private let hideMovieHandler:HideMovieFromSearchUseCase
    private let favouriteMovieHandler:AddFavouriteMovieUseCase
    
    var isLoading:Observer<Bool>?
    
    var hideMovieCompletion:Observer<Result<IndexPath, Error>>?
    
    init(movie: DomainMovie, imageLoader: ImageDataLoader, hideMovieHandler:HideMovieFromSearchUseCase, favouriteMovieHandler:AddFavouriteMovieUseCase) {
        self.model = movie
        self.imageLoader = imageLoader
        self.hideMovieHandler = hideMovieHandler
        self.favouriteMovieHandler = favouriteMovieHandler
    }
    
    public func view(in tableView: UITableView, at indexPath:IndexPath) -> SearchMovieCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchMovieCell") as! SearchMovieCell
        cell.titleLabel.text = model.title
        cell.descriptionLabel.text = model.description
        cell.ratingLabel.text = String(model.rating)
        cell.donotShowAgainButton.isHidden = model.isFavourite
        let favouriteButtonImage = model.isFavourite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        cell.favouriteButton.setImage(favouriteButtonImage, for: .normal)
        cell.movieImageView.image = nil
        cell.movieImageContainer.startShimmering()
        cell.favouriteButton.isEnabled = !model.isFavourite
        task = imageLoader.loadImageData(from: model.poster) { [weak cell] result in
            let data = try? result.get()
            cell?.movieImageView.image = data.map(UIImage.init) ?? nil
            cell?.movieImageContainer.stopShimmering()
        }
        
        cell.hideMovieAction = { [weak self] in
            guard let self = self else {return}
            self.isLoading?(true)
            
            self.hideMovieHandler.hide(self.model) { [weak self] error in
                guard let self = self else {return}
                if let error = error {
                    self.hideMovieCompletion?(.failure(error))
                } else { self.hideMovieCompletion?(.success(indexPath)) }
                
                self.isLoading?(false)
            }
        }
        
        cell.favouriteAction = { [weak self] in
            guard let self = self else {return}
            self.isLoading?(true)
            self.favouriteMovieHandler.addFavourite(self.model) { [weak self] error in
                guard let self = self else { return }
                if error == nil {
                    self.model.isFavourite = true
                }
                self.isLoading?(false)
            }
        }
        
        return cell
    }
    
    func preLoad() {
        task = imageLoader.loadImageData(from: model.poster) { _ in}
    }
    
    func cancelLoad() {
        task?.cancel()
    }

}
