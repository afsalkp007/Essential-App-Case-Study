//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Afsal on 11/02/2024.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
  func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }
  
  func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
  }
  
  func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    insert((feed, timestamp), to: sut)
    
    expect(sut, toRetrieve: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
  }

  func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    insert((feed, timestamp), to: sut)
    
    expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
  }
  
  func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
    
    XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
  }
  
  func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
    
    XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
  }
  
  func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    let latestFeed = uniqueImageFeed().local
    let latestTimestamp = Date()
    insert((latestFeed, latestTimestamp), to: sut)
    
    expect(sut, toRetrieve: .success(CachedFeed(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
  }

  func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNil(deletionError, file: file, line: line)
  }
  
  func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    deleteCache(from: sut)
    
    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }
  
  func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNil(deletionError, file: file, line: line)
  }
  
  func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    deleteCache(from: sut)
    
    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }
  
  @discardableResult
  func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
    do {
      try sut.insert(cache.feed, timestamp: cache.timestamp)
      return nil
    } catch {
      return error
    }
  }

  @discardableResult
  func deleteCache(from sut: FeedStore) -> Error? {
    do {
      try sut.deleteCachedFeed()
      return nil
    } catch {
      return error
    }
  }
  
  func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
    
    let retrieveResult = Result { try sut.retrieve() }
    
    switch (expectedResult, retrieveResult) {
    case (.success(.none), .success(.none)),
      (.failure, .failure):
      break
      
    case let (.success(expectedCache), .success(retrievedCache)):
      XCTAssertEqual(retrievedCache?.feed, expectedCache?.feed, file: file, line: line)
      XCTAssertEqual(retrievedCache?.timestamp, expectedCache?.timestamp, file: file, line: line)
      
    default:
      XCTFail("Expected found result with feed and timestamp, got instead")
    }
  }
  
  func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
}
