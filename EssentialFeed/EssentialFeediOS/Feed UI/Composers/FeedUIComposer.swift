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
    let feedViewModel = FeedViewModel(feedLoader: feedLoader)
    let refreshController = FeedRefreshController(feedViewModel: feedViewModel)
    let feedController = FeedViewController(refreshController: refreshController)
    feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
    return feedController
  }
  
  private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
    return { [weak controller] feed in
      controller?.tableModel = feed.map { model in
        FeedImageCellController(model: model, imageLoader: loader)
      }
    }
  }
}
