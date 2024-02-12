//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Afsal on 12/02/2024.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
  public init() {}

  public func retrieve(completion: @escaping RetrievalCompletion) {
    completion(.empty)
  }

  public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

  }

  public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

  }

}
 
