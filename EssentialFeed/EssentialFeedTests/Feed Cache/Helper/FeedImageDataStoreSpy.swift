//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Afsal on 22/02/2024.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
  enum Message: Equatable {
    case insert(data: Data, for: URL)
    case retrieve(dataFor: URL)
  }

  private var retrievalResult: Result<Data?, Error>?
  private var insertionResult: Result<Void, Error>?
  private(set) var receivedMessages = [Message]()
  
  func insert(_ data: Data, for url: URL) throws {
    receivedMessages.append(.insert(data: data, for: url))
    try insertionResult?.get()
  }

  func retrieve(dataForURL url: URL) throws -> Data? {
    receivedMessages.append(.retrieve(dataFor: url))
    return try retrievalResult?.get()
  }
  
  func completeRetrieval(with error: Error) {
    retrievalResult = .failure(error)
  }
  
  func completeInsertion(with error: Error) {
    insertionResult = .failure(error)
  }
  
  func complete(with data: Data?) {
    retrievalResult = .success(data)
  }
  
  func completeInsertionSuccessfully() {
    insertionResult = .success(())
  }
}
