//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 01/02/2024.
//

import Foundation

public final class RemoteFeedLoader {
  private let url: URL
  private let client: HTTPClient
     
  public enum Error: Swift.Error {
    case connectivity
    case invlalidData
  }
  
  public typealias Result = LoadFeedResult<Error>

  public init(url: URL, client: HTTPClient) {
    self.client = client
    self.url = url
  }
  
  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) { [weak self] result in
      guard self != nil else { return }
      
      switch result {
      case let .success(data, response):
        completion(FeedItemsMapper.map(data, response))
      case .failure:
        completion(.failure(.connectivity))
      }
    }
  }
}



