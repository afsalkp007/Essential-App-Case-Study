//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 31/01/2024.
//

import XCTest

class RemoteFeedLoader {

}

class HTTPClient {
  var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestDataFromURL() {
    let client = HTTPClient()
    _ = RemoteFeedLoader()
    
    XCTAssertNil(client.requestedURL)
  }
}
