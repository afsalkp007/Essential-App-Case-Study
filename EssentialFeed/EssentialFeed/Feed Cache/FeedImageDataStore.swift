//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Afsal on 22/02/2024.
//

import Foundation

public protocol FeedImageDataStore {
  typealias RetrievalResult = Swift.Result<Data?, Error>
  func insert(_ data: Data, for url: URL) throws
  func retrieve(dataForURL url: URL) throws -> Data?
}

