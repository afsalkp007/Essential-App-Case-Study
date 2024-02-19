//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Afsal on 19/02/2024.
//

import Foundation

struct FeedErrorViewModel {
  let message: String?
  
  static var noError: FeedErrorViewModel {
    return FeedErrorViewModel(message: nil)
  }

  static func error(message: String) -> FeedErrorViewModel {
    return FeedErrorViewModel(message: message)
  }
}

