//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Afsal on 08/02/2024.
//

import Foundation
import EssentialFeed

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
  let models = [uniqueImage(), uniqueImage()]
  let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
  return (models, local)
}

func uniqueImage() -> FeedImage {
  return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

extension Date {
  func minusFeedCacheMaxAge() -> Date {
    return adding(days: -feedCacehMaxAgeInDays)
  }
  
  var feedCacehMaxAgeInDays: Int {
    return 7
  }
}
