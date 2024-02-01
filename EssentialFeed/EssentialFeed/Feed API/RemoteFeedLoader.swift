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
        do {
          let items = try FeedItemsMapper.map(data, response)
          completion(.success(items))
        } catch {
          completion(.failure(.invlalidData))
        }
      case .failure:
        completion(.failure(.connectivity))
      }
    }
  }
  
  private func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
    do {
      let items = try FeedItemsMapper.map(data, response)
      return .success(items)
    } catch {
      return .failure(.invlalidData)
    }
  }
}



