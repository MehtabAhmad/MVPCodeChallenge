//
//  SearchMovieCellController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 14/01/2023.
//

import Foundation
import UIKit

final class SearchMovieCellController {
    typealias Observer<T> = (T) -> Void
    
   let viewModel:MoviesCellViewModel<UIImage>
    
    init(viewModel: MoviesCellViewModel<UIImage>) {
        
        self.viewModel = viewModel
    }
    
    public func view(in tableView: UITableView, at indexPath:IndexPath) -> SearchMovieCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchMovieCell") as! SearchMovieCell
        
        return binded(cell, at: indexPath)
    }
    
    private func binded(_ cell: SearchMovieCell, at indexPath:IndexPath) -> SearchMovieCell {
        
        cell.titleLabel.text = viewModel.title
        cell.descriptionLabel.text = viewModel.description
        cell.ratingLabel.text = viewModel.rating
        cell.donotShowAgainButton.isHidden = viewModel.isFavourite
        cell.favouriteButton.setImage(UIImage(systemName: viewModel.favouriteImageName), for: .normal)
        cell.favouriteButton.isEnabled = viewModel.isFavouriteButtonEnabled
        cell.movieImageView.image = nil
        
        viewModel.onImageLoaded = { [weak cell] image in
            cell?.movieImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isShimmering in
            cell?.movieImageContainer.isShimmering = isShimmering
        }
        
        viewModel.loadImageData()
    
        cell.hideMovieAction = { [weak self] in
            guard let self = self else {return}
            self.viewModel.hideMovie(at: indexPath)
        }
        
        cell.favouriteAction = { [weak self] in
            guard let self = self else {return}
            self.viewModel.addMovieToFavourites()
        }
        
        return cell
    }
    
    func preLoad() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelLoad()
    }

}
