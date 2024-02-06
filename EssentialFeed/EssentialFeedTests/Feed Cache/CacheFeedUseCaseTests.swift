//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 06/02/2024.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
  let store: FeedStore
  init(store: FeedStore) {
    self.store = store
  }
  
  func save(_ items: [FeedItem]) {
    store.deleteCacheFeed()
  }
}

class FeedStore {
  var deleteCachedCallCount = 0
  
  func deleteCacheFeed() {
    deleteCachedCallCount += 1
  }
}

class CacheFeedUseCaseTests: XCTestCase {
  
  func test() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.deleteCachedCallCount, 0)
  }
  
  func test_save_requestsCacheDeletion() {
    let (sut, store) = makeSUT()
    let items = [unequeItem(), unequeItem()]
    
    sut.save(items)
    
    XCTAssertEqual(store.deleteCachedCallCount, 1)

  }
  
  // MARK: - Helpers
  
  private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
    return (sut, store)
  }
  
  private func unequeItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }

}
