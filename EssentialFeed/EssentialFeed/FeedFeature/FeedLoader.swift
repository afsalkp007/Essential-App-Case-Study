//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 31/01/2024.
//

import Foundation

public enum LoadFeedResult {
  case success([FeedItem])
  case failure(Error)
}

protocol FeedLoader {
  func load(completion: @escaping (LoadFeedResult) -> Void)
}
