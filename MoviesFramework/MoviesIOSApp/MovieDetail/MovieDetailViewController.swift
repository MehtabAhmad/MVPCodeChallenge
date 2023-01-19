//
//  MovieDetailViewController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 11/01/2023.
//

import UIKit

public class MovieDetailViewController: UIViewController {
    
    @IBOutlet public private(set) var titleLabel:UILabel!
    @IBOutlet public private(set) var descriptionLabel: UILabel!
    @IBOutlet public private(set) var ratingLabel: UILabel!
    @IBOutlet public private(set) var movieImageContainer: UIView!
    @IBOutlet public private(set) var movieImageView: UIImageView!
    @IBOutlet public private(set) var favouriteButton: UIButton!
    
    var viewModel:MovieDetailViewModel<UIImage>?
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        display()
    }
    
    private func display() {
      
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        ratingLabel.text = viewModel.rating
        favouriteButton.setImage(UIImage(named: viewModel.favouriteImageName), for: .normal)
        
        viewModel.onImageLoaded = { [weak self] image in
            guard let self = self else {return}
            self.movieImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak self] isShimmering in
            self?.movieImageContainer.isShimmering = isShimmering
        }
        viewModel.loadImageData()
    }
}
