//
//  RemoteMovieLoaderTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 01/01/2023.
//

import XCTest

class RemoteMovieLoader {
    private let client:HTTPClient
    private let url:URL
    
    init(client:HTTPClient, url:URL) {
        self.client = client
        self.url = url
    }
    func load() {
        client.requestedURL = url
    }
}

class HTTPClient {
    var requestedURL: URL?
}


final class RemoteMovieLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        let url = URL(string: "https://any-url.com")!
        _ = RemoteMovieLoader(client: client, url: url)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient()
        let url = URL(string: "https://any-url.com")!
        let sut = RemoteMovieLoader(client: client, url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
}
