//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Afsal on 16/02/2024.
//

import Foundation

public protocol FeedImageDataLoader {
  func loadImageData(from url: URL) throws -> Data

}
