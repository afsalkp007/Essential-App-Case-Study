//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Afsal on 06/02/2024.
//

import Foundation

public enum RetrievedCachedFeedResult {
  case empty
  case found(feed: [LocalFeedImage], timestamp: Date)
  case failure(Error)
}

public protocol FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void
  typealias RetrievalCompletion = (RetrievedCachedFeedResult) -> Void

  func deleteCacheFeed(_ completion: @escaping DeletionCompletion)
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
  func retrieve(completion: @escaping RetrievalCompletion)
}


