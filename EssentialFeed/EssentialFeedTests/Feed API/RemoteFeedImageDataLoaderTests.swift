//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 19/02/2024.
//

import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader {
  private let client: HTTPClient
  
  init(client: HTTPClient) {
    self.client = client
  }
  
  func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
    client.get(from: url) { _ in }
  }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
  
  func test_init_doesNotPerformAnyURLRequest() {
    let (_, client) = makeSUT()
    
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }
  
  func test_loadImageDataFromURL_requestDataFromURL() {
    let (sut, client) = makeSUT()
    let url = URL(string: "https://a-given-url.com")!

    sut.loadImageData(from: url) { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  // MARK: - Helpers
  
  private func makeSUT( file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedImageDataLoader(client: client)
    trackForMemoryLeaks(client, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, client)
  }
  
  private class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URL]()
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
      requestedURLs.append(url)
    }
  }
}
