//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Afsal on 31/01/2024.
//

import Foundation

public struct FeedItem: Equatable {
  let id: UUID
  let description: String?
  let location: String?
  let imageURL: URL
}
