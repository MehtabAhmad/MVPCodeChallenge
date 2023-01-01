//
//  RemoteMovieLoaderTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 01/01/2023.
//

import XCTest

class RemoteMovieLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}


final class RemoteMovieLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteMovieLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
