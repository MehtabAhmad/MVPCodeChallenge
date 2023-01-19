//
//  FavouriteMovieCellController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 17/01/2023.
//

import Foundation
import UIKit

final class FavouriteMovieCellController {
    
    private let viewModel:FavouriteCellViewModel<UIImage>
    private var cell:FavouriteMovieCell?
    
    init(viewModel: FavouriteCellViewModel<UIImage>) {
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
        cell.movieImageView.image = nil
        
        viewModel.onImageLoaded = { [weak self] image in
            guard let self = self else {return}
            self.cell?.movieImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isShimmering in
            cell?.movieImageContainer.isShimmering = isShimmering
        }
        
        viewModel.loadImageData()
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
