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
    let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
    
    let bundle = Bundle(for: FeedViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
    feedController.delegate = presentationAdapter
    
    presentationAdapter.presenter = FeedPresenter(
      feedView: FeedViewAdapter(controller: feedController, loader: imageLoader),
      loadingView: WeakRefVirtualProxy(feedController))

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

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
  func display(_ model: FeedImageViewModel<UIImage>) {
    object?.display(model)
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
      let adapter = FeedImagePresenterAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: loader)
      let view = FeedImageCellController(delegate: adapter)

      adapter.presenter = FeedImagePresenter(
        view: WeakRefVirtualProxy(view),
        imageTransformer: UIImage.init)

      return view
    }
  }
}

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
  private let feedLoader: FeedLoader
  var presenter: FeedPresenter?
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  func didRequestFeedRefresh() {
    presenter?.didStartLoadingFeed()
    
    feedLoader.load { [weak self] result in
      switch result {
      case let .success(feed):
        self?.presenter?.didFinishLoadingFeed(with: feed)
        
      case let .failure(error):
        self?.presenter?.didFinishLoading(with: error)
      }
    }
  }
}

final class FeedImagePresenterAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
  private let model: FeedImage
  private let imageLoader: FeedImageDataLoader
  private var task: FeedImageDataLoaderTask?
  
  var presenter: FeedImagePresenter<View, Image>?
  
  init(model: FeedImage, imageLoader: FeedImageDataLoader) {
    self.model = model
    self.imageLoader = imageLoader
  }

  func didRequestImage() {
    presenter?.didStartLoadingImageData(for: model)

    let model = self.model
    task = imageLoader.loadImageData(from: model.url) { [weak self] result in
      switch result {
      case let .success(data):
        self?.presenter?.didFinishLoadingImageData(with: data, for: model)

      case let .failure(error):
        self?.presenter?.didFinishLoadingImageData(with: error, for: model)
      }
    }
  }

  func didCancelImageRequest() {
    task?.cancel()
    task = nil
  }
}


