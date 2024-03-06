//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Afsal on 22/02/2024.
//

import Foundation

public protocol FeedCache {
  func save(_ feed: [FeedImage]) throws
}
