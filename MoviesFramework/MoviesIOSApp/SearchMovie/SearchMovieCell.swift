//
//  SearchMovieCell.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 12/01/2023.
//

import Foundation
import UIKit

public class SearchMovieCell: UITableViewCell {
    @IBOutlet public private(set) var titleLabel:UILabel!
    @IBOutlet public private(set) var descriptionLabel: UILabel!
    @IBOutlet public private(set) var ratingLabel: UILabel!
    @IBOutlet public private(set) var movieImageContainer: UIView!
    @IBOutlet public private(set) var movieImageView: UIImageView!
    @IBOutlet public private(set) var donotShowAgainButton: UIButton!
    @IBOutlet public private(set) var favouriteButton: UIButton!
    
    var hideMovieAction: (() -> Void)?
    var favouriteAction: (() -> Void)?
    
    @IBAction func doNoShowAgainButtonTap(_ sender: Any) {
        hideMovieAction?()
    }
    
    @IBAction func favouriteButtonTap(_ sender: Any) {
        favouriteAction?()
    }
}
