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
    let presenter = FeedPresenter()
    let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader, presenter: presenter)
    let refreshController = FeedRefreshController(delegate: presentationAdapter)
    let feedController = FeedViewController(refreshController: refreshController)
    presenter.loadingView = WeakRefVirtualProxy(refreshController)
    presenter.feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)
    return feedController
  }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
  private weak var object: T?
  
  init(_ object: T) {
    self.object = object
  }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel) {
    object?.display(viewModel)
  }
}

final class FeedViewAdapter: FeedView {
  private weak var controller: FeedViewController?
  private let loader: FeedImageDataLoader
  
  init(controller: FeedViewController, loader: FeedImageDataLoader) {
    self.controller = controller
    self.loader = loader
  }
  
  func display(_ viewModel: FeedViewModel) {
    controller?.tableModel = viewModel.feed.map { model in
      FeedImageCellController(viewModel: FeedImageCellViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
    }
  }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshControllerDelegate {
  private let feedLoader: FeedLoader
  private let presenter: FeedPresenter
  
  init(feedLoader: FeedLoader, presenter: FeedPresenter) {
    self.feedLoader = feedLoader
    self.presenter = presenter
  }
  
  func didRequestFeedRefresh() {
    presenter.didStartLoadingFeed()
    
    feedLoader.load { [weak self] result in
      switch result {
      case let .success(feed):
        self?.presenter.didFinishLoadingFeed(with: feed)
        
      case let .failure(error):
        self?.presenter.didFinishLoading(with: error)
      }
    }
  }
}
