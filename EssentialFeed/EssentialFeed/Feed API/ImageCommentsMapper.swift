//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Afsal on 26/02/2024.
//

import Foundation

final class ImageCommentsMapper {
  
  private struct Root: Decodable {
    let items: [RemoteFeedItem]
  }

  static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
    guard isOK(response),
          let root = try? JSONDecoder().decode(Root.self, from: data) else {
      throw RemoteImageCommentsLoader.Error.invlalidData
    }
    
    return root.items
  }
  
  private static func isOK(_ response: HTTPURLResponse) -> Bool {
    (200...299).contains(response.statusCode)
  }
}

private extension Array where Element == FeedImage {
  func toRemote() -> [RemoteFeedItem] {
    return map { RemoteFeedItem(id: $0.id, description: $0.description, location: $0.location, image: $0.url) }
  }
}
