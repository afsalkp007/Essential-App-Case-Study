//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Afsal on 16/02/2024.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
  private init() {}
  
  public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let presenter = FeedPresenter(feedLoader: feedLoader)
    let refreshController = FeedRefreshController(presenter: presenter)
    let feedController = FeedViewController(refreshController: refreshController)
    presenter.loadingView = refreshController
    presenter.feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)
    return feedController
  }
}

final class FeedViewAdapter: FeedView {
  private weak var controller: FeedViewController?
  private let loader: FeedImageDataLoader
  
  init(controller: FeedViewController, loader: FeedImageDataLoader) {
    self.controller = controller
    self.loader = loader
  }
  
  func display(feed: [FeedImage]) {
    controller?.tableModel = feed.map { model in
      FeedImageCellController(viewModel: FeedImageCellViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
    }
  }
}
