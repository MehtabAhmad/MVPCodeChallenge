//
//  MovieCell.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 11/01/2023.
//

import UIKit

public final class FavouriteMovieCell: UITableViewCell {
    
    @IBOutlet public private(set) var titleLabel: UILabel!
    @IBOutlet public private(set) var ratingLabel: UILabel!
    @IBOutlet public private(set) var movieImageContainer: UIView!
    @IBOutlet public private(set) var movieImageView: UIImageView!
    @IBOutlet public private(set) var descriptionLabel: UILabel!
    
}
