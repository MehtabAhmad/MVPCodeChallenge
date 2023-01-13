//
//  FavouriteMoviesViewController.swift
//  MoviesIOSApp
//
//  Created by Mehtab on 11/01/2023.
//

import UIKit

class FavouriteMoviesViewController: UITableViewController {

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieCell
        cell.fadeIn(UIImage(named: "image-\(indexPath.row)"))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.show(MovieDetailViewController(), sender: self)
    }
    
    
    @IBAction func searchAction(_ sender: Any) {
        
    }
}
