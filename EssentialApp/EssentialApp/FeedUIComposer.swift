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
  
  private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

  public static func feedComposedWith(
    feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
      imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
      selection: @escaping (FeedImage) -> Void = { _ in }
  ) -> ListViewController {
  let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)

    let feedController = makeWith(
      title: FeedPresenter.title)
    feedController.onRefresh = presentationAdapter.loadResource
      
    presentationAdapter.presenter = LoadResourcePresenter(
      resourceView: FeedViewAdapter(
        controller: feedController,
        imageLoader: imageLoader,
        selection: selection),
      loadingView: WeakRefVirtualProxy(feedController),
      errorView: WeakRefVirtualProxy(feedController),
      mapper: { $0 })

    return feedController
  }
  
  private static func makeWith(title: String) -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController() as! ListViewController
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
  private weak var controller: ListViewController?
  private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
  private let selection: (FeedImage) -> Void

  init(controller: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher, selection: @escaping (FeedImage) -> Void) {
    self.controller = controller
    self.imageLoader = imageLoader
    self.selection = selection
  }
  
  func display(_ viewModel: Paginated<FeedImage>) {
    controller?.display(viewModel.items.map { model in
      let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(loader: { [imageLoader] in
        imageLoader(model.url)
      })
      let view = FeedImageCellController(
        viewModel: FeedImagePresenter.map(model),
        delegate: adapter,
        selection: { [selection] in
            selection(model)
        })

      adapter.presenter = LoadResourcePresenter(
        resourceView: WeakRefVirtualProxy(view),
        loadingView: WeakRefVirtualProxy(view),
        errorView: WeakRefVirtualProxy(view),
        mapper: UIImage.tryMake)

      return CellController(id: model, view)
    })
  }
}


extension UIImage {
  private struct InvalidData: Error {}

  static func tryMake(_ data: Data) throws -> UIImage {
    guard let image = UIImage(data: data) else {
      throw InvalidData()
    }
    return image
  }
}
