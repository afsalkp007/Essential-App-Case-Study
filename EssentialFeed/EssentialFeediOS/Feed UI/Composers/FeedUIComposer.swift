//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Afsal on 16/02/2024.
//

import EssentialFeed

public final class FeedUIComposer {
  private init() {}
  
  public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let refreshController = FeedRefreshController(feedLoader: feedLoader)
    let feedController = FeedViewController(refreshController: refreshController)
    refreshController.onRefresh = { [weak feedController] feed in
      feedController?.tableModel = feed.map { model in
        FeedImageCellController(model: model, imageLoader: imageLoader)
      }
    }
    return feedController
  }
}
