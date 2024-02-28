//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 27/02/2024.
//

import Foundation

public final class RemoteLoader<Resource> {
  private let url: URL
  private let client: HTTPClient
  private let mapper: Mapper
     
  public enum Error: Swift.Error {
    case connectivity
    case invlalidData
  }
  
  public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
  public typealias Result = Swift.Result<Resource, Swift.Error>

  public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
    self.client = client
    self.url = url
    self.mapper = mapper
  }
  
  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case let .success((data, response)):
        return completion(self.map(data, from: response))
      case .failure:
        completion(.failure(Error.connectivity))
      }
    }
  }
  
  private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
    do {
      return .success(try mapper(data, response))
    } catch {
      return .failure(Error.invlalidData)
    }
  }
}
