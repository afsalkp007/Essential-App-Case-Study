//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Afsal on 19/02/2024.
//

import Foundation

struct FeedImageViewModel<Image> {
  var description: String?
  var location: String?
  let image: Image?
  let isLoading: Bool
  let shouldRetry: Bool
  
  var hasLocation: Bool {
    return location != nil
  }
}
