//
//  SearchMovieCell+TestHelpers.swift
//  MoviesIOSAppTests
//
//  Created by Mehtab on 13/01/2023.
//

import Foundation
import UIKit
import MoviesIOSApp

extension SearchMovieCell {
    var titleText:String? {
        return titleLabel.text
    }
    
    var descriptionText:String? {
        return descriptionLabel.text
    }
    
    var ratingText:String? {
        return ratingLabel.text
    }
    
    var isDoNotShowAgainButtonShowing:Bool {
        return !donotShowAgainButton.isHidden
    }
    
    var isFavouriteButtonHighlighted:Bool {
        return favouriteButton.currentImage === UIImage(systemName: "heart.fill")
    }
    
    var isFavouriteButtonEnabled:Bool {
        return favouriteButton.isEnabled
    }
    
    var isShowingImageLoadingIndicator:Bool {
        return movieImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        return movieImageView.image?.pngData()
    }
    
    func simulateDoNotShowAgainAction() {
        donotShowAgainButton.simulateTap()
    }
    
    func simulateFavouriteAction() {
        favouriteButton.simulateTap()
    }
}
