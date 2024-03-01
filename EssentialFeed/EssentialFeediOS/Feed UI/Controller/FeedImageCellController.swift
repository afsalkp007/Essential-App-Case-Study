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

public final class FeedImageCellController: CellController, ResourceView, ResourceLoadingView, ResourceErrorView {
  public typealias ResourceViewModel = UIImage
  
  private let viewModel: FeedImageViewModel
  private let delegate: FeedImageCellControllerDelegate
  private var cell: FeedImageCell?
  
  public init(viewModel: FeedImageViewModel, delegate: FeedImageCellControllerDelegate) {
    self.viewModel = viewModel
    self.delegate = delegate
  }
  
  public func view(in tableView: UITableView) -> UITableViewCell {
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
    
  public func display(_ viewModel: UIImage) {
    cell?.feedImageView.setImageAnimated(viewModel)
  }
  
  public func display(_ viewModel: ResourceLoadingViewModel) {
    cell?.feedImageContainer.isShimmering = viewModel.isLoading
  }
  
  public func display(_ viewModel: ResourceErrorViewModel) {
    cell?.feedImageRetryButton.isHidden = viewModel.message == nil
  }
    
  public func preload() {
    delegate.didRequestImage()
  }
  
  private func releaseCellForReuse() {
    cell?.onReuse = nil
    cell = nil
  }
  
  public func cancelLoad() {
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
