//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Afsal on 19/02/2024.
//

import Foundation

public struct FeedImageViewModel<Image> {
  public var description: String?
  public var location: String?
  public let image: Image?
  public let isLoading: Bool
  public let shouldRetry: Bool
  
  var hasLocation: Bool {
    return location != nil
  }
}
