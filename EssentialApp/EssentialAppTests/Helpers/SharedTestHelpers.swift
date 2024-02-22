//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Afsal on 22/02/2024.
//

import Foundation
import EssentialFeed

func anyURL() -> URL {
  return URL(string: "http://a-url.com")!
}

func anyNSError() -> NSError {
  return NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
  return Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
  return [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}

