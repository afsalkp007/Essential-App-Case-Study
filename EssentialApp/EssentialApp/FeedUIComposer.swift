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
  let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: feedLoader)

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

extension WeakRefVirtualProxy: ResourceView where T: ResourceView, T.ResourceViewModel == UIImage {
  func display(_ model: UIImage) {
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
      let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(loader: { [imageLoader] in
        imageLoader(model.url)
      })
      let view = FeedImageCellController(
        viewModel: FeedImagePresenter.map(model),
        delegate: adapter)

      adapter.presenter = LoadResourcePresenter(
        resourceView: WeakRefVirtualProxy(view),
        loadingView: WeakRefVirtualProxy(view),
        errorView: WeakRefVirtualProxy(view),
        mapper: { data in
          guard let image = UIImage(data: data) else {
            throw InvalidData()
          }
          return image
        })

      return view
    })
  }
}

private struct InvalidData: Error {}


