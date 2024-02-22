//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Afsal on 22/02/2024.
//

import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
  private let decoratee: FeedLoader
  private let cache: FeedCache
  
  public init(decoratee: FeedLoader, cache: FeedCache) {
    self.decoratee = decoratee
    self.cache = cache
  }

  public func load(completion: @escaping (FeedLoader.Result) -> Void) {
    decoratee.load { [weak self] result in
      completion(result.map { feed in
        self?.cache.save(feed) { _ in }
        return feed
      })
    }
  }
}
