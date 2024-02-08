//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Afsal on 08/02/2024.
//

import Foundation
import EssentialFeed

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
  let models = [unequeImage(), unequeImage()]
  let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
  return (models, local)
}

func unequeImage() -> FeedImage {
  return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

extension Date {
  func minusFeedCacheMaxAge() -> Date {
    return adding(days: -7)
  }
  
  func adding(days: Int) -> Date {
    return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }
  
  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
}

