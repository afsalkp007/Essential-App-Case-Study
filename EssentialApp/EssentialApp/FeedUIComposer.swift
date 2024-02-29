//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Afsal on 16/02/2024.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
  private init() {}
  
  public static func feedComposedWith(
      feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
      imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
  ) -> FeedViewController {
  let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)

    let feedController = makeWith(
      delegate: presentationAdapter,
      title: FeedPresenter.title)
      
    presentationAdapter.presenter = LoadResourcePresenter(
      resourceView: FeedViewAdapter(
        controller: feedController,
        imageLoader: imageLoader),
      loadingView: WeakRefVirtualProxy(feedController),
      errorView: WeakRefVirtualProxy(feedController),
      mapper: FeedPresenter.map)

    return feedController
  }
  
  private static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
    let bundle = Bundle(for: FeedViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
    feedController.delegate = delegate
    feedController.title = title
    return feedController
  }
}

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
  func display(_ viewModel: ResourceErrorViewModel) {
    object?.display(viewModel)
  }
}
  
private final class WeakRefVirtualProxy<T: AnyObject> {
  private weak var object: T?
  
  init(_ object: T) {
    self.object = object
  }
}

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
  func display(_ viewModel: ResourceLoadingViewModel) {
    object?.display(viewModel)
  }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
  func display(_ model: FeedImageViewModel<UIImage>) {
    object?.display(model)
  }
}


final class FeedViewAdapter: ResourceView {
  private weak var controller: FeedViewController?
  private let imageLoader: (URL) -> FeedImageDataLoader.Publisher

  init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
    self.controller = controller
    self.imageLoader = imageLoader
  }
  
  func display(_ viewModel: FeedViewModel) {
    controller?.display(viewModel.feed.map { model in
      let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
      let view = FeedImageCellController(delegate: adapter)

      adapter.presenter = FeedImagePresenter(
        view: WeakRefVirtualProxy(view),
        imageTransformer: UIImage.init)

      return view
    })
  }
}

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
  private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    private var cancellable: Cancellable?
  var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
  
  init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
    self.feedLoader = feedLoader
  }
  
  func didRequestFeedRefresh() {
    presenter?.didStartLoading()
    
    cancellable = feedLoader()
        .dispatchOnMainQueue()
        .sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break

                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)
                }
            }, receiveValue: { [weak self] feed in
                self?.presenter?.didFinishLoading(with: feed)
            })
  }
}

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
  private let model: FeedImage
  private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
  private var cancellable: Cancellable?

  var presenter: FeedImagePresenter<View, Image>?
  
  init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
    self.model = model
    self.imageLoader = imageLoader
  }

  func didRequestImage() {
    presenter?.didStartLoadingImageData(for: model)

    let model = self.model
    cancellable = imageLoader(model.url)
        .dispatchOnMainQueue()
        .sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break

                case let .failure(error):
                    self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                }

            }, receiveValue: { [weak self] data in
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            })
  }

  func didCancelImageRequest() {
    cancellable?.cancel()
    cancellable = nil
  }
}


