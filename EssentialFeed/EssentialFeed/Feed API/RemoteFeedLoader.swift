//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 01/02/2024.
//

import Foundation

public enum HTTPClientResult {
  case success(Data, HTTPURLResponse)
  case failure(Error)
}

public protocol HTTPClient {
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
  private let url: URL
  private let client: HTTPClient
  
  public enum Result: Equatable {
    case success([FeedItem])
    case failure(Error)
  }
   
  public enum Error: Swift.Error {
    case connectivity
    case invlalidData
  }
  
  public init(url: URL, client: HTTPClient) {
    self.client = client
    self.url = url
  }
  
  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) { result in
      switch result {
      case let .success(data, response):
        if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
          completion(.success(root.items))
        } else {
          completion(.failure(.invlalidData))
        }
      case .failure:
        completion(.failure(.connectivity))
      }
    }
  }
}

private struct Root: Decodable {
  let items: [FeedItem]
}
