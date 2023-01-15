//
//  UITableView+Dequeuing.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 15/01/2023.
//

import Foundation
import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
