//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 01/02/2024.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
  private let url: URL
  private let client: HTTPClient
     
  public enum Error: Swift.Error {
    case connectivity
    case invlalidData
  }
  
  public typealias Result = LoadFeedResult

  public init(url: URL, client: HTTPClient) {
    self.client = client
    self.url = url
  }
  
  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) { [weak self] result in
      guard self != nil else { return }
      
      switch result {
      case let .success(data, response):
        return completion(Self.map(data, from: response))
      case .failure:
        completion(.failure(Error.connectivity))
      }
    }
  }
  
  private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
    do {
      let items = try FeedItemsMapper.map(data, response)
      return .success(items.toModels())
    } catch {
      return .failure(error)
    }

  }
}

extension Array where Element == RemoteFeedItem {
  func toModels() -> [FeedItem] {
    return map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
  }
}



