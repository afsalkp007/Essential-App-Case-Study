//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Afsal on 06/02/2024.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)
 
public protocol FeedStore {
  func deleteCachedFeed() throws
  func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
  func retrieve() throws -> CachedFeed?
}


