//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 16/02/2024.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
  func didRequestImage()
  func didCancelImageRequest()
}

public final class FeedImageCellController: NSObject {
  public typealias ResourceViewModel = UIImage
  
  private let viewModel: FeedImageViewModel
  private let delegate: FeedImageCellControllerDelegate
  private var cell: FeedImageCell?
  
  public init(viewModel: FeedImageViewModel, delegate: FeedImageCellControllerDelegate) {
    self.viewModel = viewModel
    self.delegate = delegate
  }
}
 
extension FeedImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
  public func display(_ viewModel: UIImage) {
    cell?.feedImageView.setImageAnimated(viewModel)
  }
  
  public func display(_ viewModel: ResourceLoadingViewModel) {
    cell?.feedImageContainer.isShimmering = viewModel.isLoading
  }
  
  public func display(_ viewModel: ResourceErrorViewModel) {
    cell?.feedImageRetryButton.isHidden = viewModel.message == nil
  }
}

extension FeedImageCellController: CellController {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cell = tableView.dequeueReusableCell()
    cell?.locationContainer.isHidden = !viewModel.hasLocation
    cell?.locationLabel.text = viewModel.location
    cell?.descriptionLabel.text = viewModel.description
    delegate.didRequestImage()
    cell?.onRetry = delegate.didRequestImage
    cell?.onReuse = { [weak self] in
      self?.releaseCellForReuse()
    }
    return cell!
  }
  
  public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cancelLoad()
  }
  
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    delegate.didRequestImage()
  }

  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    cancelLoad()
  }
  
  private func releaseCellForReuse() {
    cell?.onReuse = nil
    cell = nil
  }
  
  private func cancelLoad() {
    releaseCellForReuse()
    delegate.didCancelImageRequest()
  }
}

extension UIImageView {
  func setImageAnimated(_ newImage: UIImage?) {
    image = newImage
    
    if newImage != nil {
      alpha = 0
      UIView.animate(withDuration: 0.25) {
        self.alpha = 1
      }
    }
  }
}

extension UITableView {
  func dequeueReusableCell<T: UITableViewCell>() -> T {
    let identifier = String(describing: T.self)
    return dequeueReusableCell(withIdentifier: identifier) as! T
  }
}
