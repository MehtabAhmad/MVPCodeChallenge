//
//  SearchMovieCellController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 14/01/2023.
//

import Foundation
import UIKit

final class SearchMovieCellController {
    
    private let viewModel:MoviesCellViewModel<UIImage>
    private var cell:SearchMovieCell?
    
    init(viewModel: MoviesCellViewModel<UIImage>) {
        
        self.viewModel = viewModel
    }
    
    public func view(in tableView: UITableView, at indexPath:IndexPath) -> UITableViewCell {
        
        cell = tableView.dequeueReusableCell()
        binded(indexPath)
        return cell!
    }
    
    private func binded(_ indexPath:IndexPath) {
        
        guard let cell = cell else {return}
        
        cell.titleLabel.text = viewModel.title
        cell.descriptionLabel.text = viewModel.description
        cell.ratingLabel.text = viewModel.rating
        cell.donotShowAgainButton.isHidden = viewModel.isFavourite
        cell.favouriteButton.setImage(UIImage(named: viewModel.favouriteImageName), for: .normal)
        cell.favouriteButton.isUserInteractionEnabled = viewModel.isFavouriteButtonEnabled
        cell.movieImageView.image = nil
        
        viewModel.onImageLoaded = { [weak self] image in
            guard let self = self else {return}
            self.cell?.movieImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isShimmering in
            cell?.movieImageContainer.isShimmering = isShimmering
        }
        
        viewModel.onFavourite = { [weak self] in
            guard let self = self else {return}
            cell.favouriteButton.setImage(UIImage(named: self.viewModel.favouriteImageName), for: .normal)
            cell.donotShowAgainButton.isHidden = self.viewModel.isFavourite
            cell.favouriteButton.isUserInteractionEnabled = self.viewModel.isFavouriteButtonEnabled
            cell.layoutSubviews()
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
        
    }
    
    func preLoad() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelLoad()
        releaseCellForReuse()
    }
    
    private func releaseCellForReuse() {
         cell = nil
    }
}
