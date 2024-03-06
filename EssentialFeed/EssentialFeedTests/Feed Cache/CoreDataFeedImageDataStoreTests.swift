//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 22/02/2024.
//

import XCTest
import EssentialFeed

class CoreDataFeedImageDataStoreTests: XCTestCase {

  func test_retrieveImageData_deliversNotFoundWhenEmpty() {
    let sut = makeSUT()

    expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
  }
  
  func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
    let sut = makeSUT()
    let url = URL(string: "http://a-url.com")!
    let nonMatchingURL = URL(string: "http://another-url.com")!

    insert(anyData(), for: url, into: sut)

    expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
  }
  
  // - MARK: Helpers

  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
    let storeURL = URL(fileURLWithPath: "/dev/null")
    let sut = try! CoreDataFeedStore(storeURL: storeURL)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }

  private func notFound() -> FeedImageDataStore.RetrievalResult {
    return .success(.none)
  }
  
  private func found(_ data: Data) -> FeedImageDataStore.RetrievalResult {
    return .success(data)
  }
  
  private func localImage(url: URL) -> LocalFeedImage {
    return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
  }

  private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL,  file: StaticString = #file, line: UInt = #line) {
    let receivedResult = Result { try sut.retrieve(dataForURL: url) }

    switch (receivedResult, expectedResult) {
    case let (.success( receivedData), .success(expectedData)):
      XCTAssertEqual(receivedData, expectedData, file: file, line: line)

    default:
      XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
      }
    }
  
  private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #filePath, line: UInt = #line) {
    do {
      try sut.insert(data, for: url)
    } catch {
      XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
    }
  }
}
