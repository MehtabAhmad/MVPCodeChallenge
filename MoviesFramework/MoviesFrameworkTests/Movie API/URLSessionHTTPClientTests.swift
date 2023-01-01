//
//  URLSessionHTTPClientTests.swift
//  MoviesFrameworkTests
//
//  Created by Mehtab on 01/01/2023.
//

import XCTest

final class URLSessionHTTPClientTests: XCTestCase {
    
    
    
    
    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {}
        
        override func stopLoading() {}
    }
}
