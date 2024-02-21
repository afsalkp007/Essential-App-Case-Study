//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 16/02/2024.
//

import UIKit
import EssentialFeed

protocol FeedImageCellControllerDelegate {
  func didRequestImage()
  func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
  private let delegate: FeedImageCellControllerDelegate
  private var cell: FeedImageCell?
  
  init(delegate: FeedImageCellControllerDelegate) {
    self.delegate = delegate
  }
  
  func view(in tableView: UITableView) -> UITableViewCell {
    cell = tableView.dequeueReusableCell()
    delegate.didRequestImage()
    return cell!
  }
  
  func display(_ viewModel: FeedImageViewModel<UIImage>) {
    cell?.locationContainer.isHidden = !viewModel.hasLocation
    cell?.locationLabel.text = viewModel.location
    cell?.descriptionLabel.text = viewModel.description
    cell?.feedImageView.setImageAnimated(viewModel.image)
    cell?.feedImageContainer.isShimmering = viewModel.isLoading
    cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
    
    cell?.onRetry = delegate.didRequestImage
    cell?.onReuse = { [weak self] in
      self?.releaseCellForReuse()
    }
  }
    
  func preload() {
    delegate.didRequestImage()
  }
  
  private func releaseCellForReuse() {
    cell?.onReuse = nil
    cell = nil
  }
  
  func cancelLoad() {
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
