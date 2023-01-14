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
    private let imageLoader: ImageDataLoader?
    private var task: ImageDataLoaderTask?
    
    init(movie: DomainMovie, imageLoader: ImageDataLoader?) {
        self.model = movie
        self.imageLoader = imageLoader
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
        task = imageLoader?.loadImageData(from: model.poster) { [weak cell] result in
            let data = try? result.get()
            cell?.movieImageView.image = data.map(UIImage.init) ?? nil
            cell?.movieImageContainer.stopShimmering()
        }
        
        
        return cell
    }
    
    func preLoad() {
        task = imageLoader?.loadImageData(from: model.poster) { _ in}
    }
    

    func cancelLoad() {
        task?.cancel()
    }
}
