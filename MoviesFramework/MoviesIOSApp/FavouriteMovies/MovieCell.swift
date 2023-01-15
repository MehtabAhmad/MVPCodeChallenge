//
//  MovieCell.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 11/01/2023.
//

import UIKit

final class MovieCell: UITableViewCell {
    
    @IBOutlet private(set) var movieTitle: UILabel!
    @IBOutlet private(set) var movieRating: UILabel!
    @IBOutlet private(set) var movieImageContainer: UIView!
    @IBOutlet private(set) var movieImageView: UIImageView!
    @IBOutlet private(set) var movieDescription: UILabel!
    @IBOutlet private(set) var donotShowAgainButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        movieImageView.alpha = 0
        movieImageContainer.isShimmering = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movieImageView.alpha = 0
        movieImageContainer.isShimmering = true
    }
    
    func fadeIn(_ image: UIImage?) {
        movieImageView.image = image
        
        UIView.animate (
            withDuration: 0.25,
            delay: 1.25,
            options: [],
            animations: {
                self.movieImageView.alpha = 1
            }, completion: { completed in
                if completed {
                    self.movieImageContainer.isShimmering = false
                }
            })
    }
}
