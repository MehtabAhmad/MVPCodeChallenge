//
//  RemoteMovieLoader.swift
//  MoviesFramework
//
//  Created by Mehtab on 01/01/2023.
//

import Foundation

public protocol HTTPClient {
    func get(from url:URL, completion:@escaping (Error) -> Void)
}

final public class RemoteMovieLoader {
    private let client:HTTPClient
    private let url:URL
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(client:HTTPClient, url:URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion:@escaping (Error) -> Void) {
        client.get(from: url, completion: { error in
            completion(.connectivity)
        })
    }
}
