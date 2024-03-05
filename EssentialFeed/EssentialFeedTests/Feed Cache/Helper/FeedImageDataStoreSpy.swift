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

  private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
  private var insertionResult: Result<Void, Error>?
  private(set) var receivedMessages = [Message]()
  
  func insert(_ data: Data, for url: URL) throws {
    receivedMessages.append(.insert(data: data, for: url))
    try insertionResult?.get()
  }

  func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
    receivedMessages.append(.retrieve(dataFor: url))
    retrievalCompletions.append(completion)
  }
  
  func completeRetrieval(with error: Error, at index: Int = 0) {
    retrievalCompletions[index](.failure(error))
  }
  
  func completeInsertion(with error: Error) {
    insertionResult = .failure(error)
  }
  
  func complete(with data: Data?, at index: Int = 0) {
    retrievalCompletions[index](.success(data))
  }
  
  func completeInsertionSuccessfully() {
    insertionResult = .success(())
  }
}
