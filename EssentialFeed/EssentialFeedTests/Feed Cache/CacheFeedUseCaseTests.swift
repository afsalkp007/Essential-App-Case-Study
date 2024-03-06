//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 06/02/2024.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {
  
  func test_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessages, [])
  }
    
  func test_save_doesNotRequestInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()
    store.completeDeletion(with: deletionError)

    try? sut.save(uniqueImageFeed().models)

    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])

  }
  
  func test_save_requestNewCacheInsertionWithTimestampOnSuccesfulDeletion() {
    let timestamp = Date()
    let (sut, store) = makeSUT(currentDate: { timestamp })
    store.completeDeletionSuccessfully()
    let feed = uniqueImageFeed()

    try? sut.save(feed.models)
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timestamp)])
  }
  
  func test_save_failsOnDeletionError() {
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()
    
    expect(sut, toCompleteWithError: deletionError, when: {
      store.completeDeletion(with: deletionError)
    })
  }
  
  func test_save_failsOnInsertionError() {
    let (sut, store) = makeSUT()
    let insertionError = anyNSError()
    
    expect(sut, toCompleteWithError: insertionError, when: {
      store.completeDeletionSuccessfully()
      store.completeInsertion(with: insertionError)
    })
  }
  
  func test_save_suceedsOnSuccessfulCacheInsertion() {
    let (sut, store) = makeSUT()
    
    expect(sut, toCompleteWithError: nil, when: {
      store.completeDeletionSuccessfully()
      store.completeInsertionSuccessfully()
    })
  }
  
  // MARK: - Helpers
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }
  
  private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (models, local)
  }
  
  private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    action()
        
    do {
      try sut.save(uniqueImageFeed().models)
    } catch {
      XCTAssertEqual(error as NSError?, expectedError, file: file, line: line)
    }
  }

}
