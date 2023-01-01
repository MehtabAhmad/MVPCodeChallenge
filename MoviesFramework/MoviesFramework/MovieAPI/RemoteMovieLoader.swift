//
//  RemoteMovieLoader.swift
//  MoviesFramework
//
//  Created by Mehtab on 01/01/2023.
//

import Foundation

public protocol HTTPClient {
    func get(from url:URL)
}

final public class RemoteMovieLoader {
    private let client:HTTPClient
    private let url:URL
    
    public init(client:HTTPClient, url:URL) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}
