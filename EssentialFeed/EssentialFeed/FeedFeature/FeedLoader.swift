//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 31/01/2024.
//

import Foundation

enum LoadFeedResult {
  case success([FeedItem])
  case error(Error)
}

protocol FeedLoader {
  func load(completion: @escaping () -> Void)
}
