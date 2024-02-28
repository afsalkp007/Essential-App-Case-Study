//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 19/02/2024.
//

import XCTest
import EssentialFeed

class FeedImageDataMapperTests: XCTestCase {

  func test_map_throwsErrorOnNon200HTTPResponse() throws {
    let samples = [199, 201, 300, 400, 500]

    try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(anyData(), from: HTTPURLResponse(statusCode: code))
            )
    }
  }

  func test_map_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let emptyData = Data()

        XCTAssertThrowsError(
            try FeedImageDataMapper.map(emptyData, from: HTTPURLResponse(statusCode: 200))
        )
  }

  func test_map_deliversReceivedNonEmptyDataOn200HTTPResponse() throws {
    let nonEmptyData = Data("non-empty data".utf8)

        let result = try FeedImageDataMapper.map(nonEmptyData, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, nonEmptyData)
  }

}

private extension HTTPURLResponse {
  convenience init(statusCode: Int) {
    self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
  }
}


 
