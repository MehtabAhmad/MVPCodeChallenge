//
//  UIButton+TestHelpers.swift
//  MoviesIOSAppTests
//
//  Created by Mehtab on 13/01/2023.
//

import Foundation
import UIKit

extension UIButton {
    func simulateTap() {
        sendActions(for: .touchUpInside)
    }
}
