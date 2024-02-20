//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Afsal on 01/02/2024.
//

import Foundation



internal final class FeedItemsMapper {
  
  private struct Root: Decodable {
    let items: [RemoteFeedItem]
  }

  internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
    guard response.isOK,
          let root = try? JSONDecoder().decode(Root.self, from: data) else {
      throw RemoteFeedLoader.Error.invlalidData
    }
    
    return root.items
  }
}

extension Array where Element == FeedImage {
  func toRemote() -> [RemoteFeedItem] {
    return map { RemoteFeedItem(id: $0.id, description: $0.description, location: $0.location, image: $0.url) }
  }
}
