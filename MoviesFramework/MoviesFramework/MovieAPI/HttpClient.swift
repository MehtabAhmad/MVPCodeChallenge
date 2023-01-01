//
//  HttpClient.swift
//  MoviesFramework
//
//  Created by Mehtab on 01/01/2023.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
