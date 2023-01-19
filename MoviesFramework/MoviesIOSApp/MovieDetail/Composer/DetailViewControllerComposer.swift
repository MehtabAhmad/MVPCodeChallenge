//
//  DetailViewControllerComposer.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 19/01/2023.
//

import Foundation
import UIKit
import MoviesFramework

public final class DetailViewControllerComposer {
    
    private init() {}
    
    public static func compose(model: DomainMovie, imageLoader: ImageDataLoader) -> MovieDetailViewController {
                
        let viewModel = MovieDetailViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init)
        
        let viewController = MovieDetailViewController()
        viewController.viewModel = viewModel
      
        return viewController
    }
}
