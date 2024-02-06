//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 06/02/2024.
//

import XCTest

class LocalFeedLoader {
  init(store: FeedStore) {
    
  }
}

class FeedStore {
  var deleteCachedCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {
  
  func test() {
    let store = FeedStore()
    _ = LocalFeedLoader(store: store)
    
    XCTAssertEqual(store.deleteCachedCallCount, 0)
  }
}
