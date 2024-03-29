//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 06/02/2024.
//

import Foundation


public class LocalFeedLoader {
  private let store: FeedStore
  private let currentDate: () -> Date
    
  public init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
}
 
extension LocalFeedLoader {
  public typealias SaveResult = Result<Void, Error>

  public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
    store.deleteCachedFeed { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case .success:
        self.cache(feed, with: completion)
        
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
  
  private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
    store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
      guard self != nil else { return }
      
      completion(error)
    }
  }
}
 
extension LocalFeedLoader: FeedLoader {
  public typealias LoadResult = FeedLoader.Result

  public func load(completion: @escaping (LoadResult) -> Void) {
    store.retrieve { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case let .failure(error):
        completion(.failure(error))
        
      case let .success(cache):
        guard let cache = cache, FeedCachePolicy.validate(cache.timestamp, against: currentDate()) else {
          completion(.success([]))
          return
        }
        completion(.success(cache.feed.toModels()))
      }
    }
  }
  
}

extension LocalFeedLoader {
  public func validateCache() {
    store.retrieve { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case .failure:
        self.store.deleteCachedFeed { _ in }
        
      case let .success(cache):
        guard let cache = cache, !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) else { return }
        self.store.deleteCachedFeed { _ in }
      }
    }
  }
}

private extension Array where Element == FeedImage {
  func toLocal() -> [LocalFeedImage] {
    return map { LocalFeedImage(id: $0.id,
                               description: $0.description,
                               location: $0.location,
                               url: $0.url) }
  }
}

private extension Array where Element == LocalFeedImage {
  func toModels() -> [FeedImage] {
    return map { FeedImage(id: $0.id,
                               description: $0.description,
                               location: $0.location,
                               url: $0.url) }
  }
}
