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
    
    var model: DomainMovie
    private let imageLoader: ImageDataLoader
    private var task: ImageDataLoaderTask?
    private let hideMovieHandler:HideMovieFromSearchUseCase
    var isLoading:((Bool) -> Void)?
    
    var hideMovieCompletion:((Result<SearchMovieCellController, Error>) -> Void)?
    
    
    init(movie: DomainMovie, imageLoader: ImageDataLoader, hideMovieHandler:HideMovieFromSearchUseCase) {
        self.model = movie
        self.imageLoader = imageLoader
        self.hideMovieHandler = hideMovieHandler
    }
    
    public func view(in tableView: UITableView) -> SearchMovieCell {
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
                self.hideMovieCompletion?(self.result(from: error))
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
    
    private func result(from error:Error?) -> Result<SearchMovieCellController, Error> {
        guard let error = error else { return .success(self) }
        return .failure(error)
    }
}
