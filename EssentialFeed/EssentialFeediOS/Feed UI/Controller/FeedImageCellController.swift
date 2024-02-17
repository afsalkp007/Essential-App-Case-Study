//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 16/02/2024.
//

import UIKit

final class FeedImageCellController {
  private var viewModel: FeedImageCellViewModel<UIImage>
  
  init(viewModel: FeedImageCellViewModel<UIImage>) {
    self.viewModel = viewModel
  }
  
  func view() -> UITableViewCell {
    let cell = binded(FeedImageCell())
    viewModel.loadImageData()
    return cell
  }
  
  private func binded(_ cell: FeedImageCell) -> FeedImageCell {
    cell.locationContainer.isHidden = !viewModel.hasLocation
    cell.locationLabel.text = viewModel.location
    cell.descriptionLabel.text = viewModel.description
    cell.onRetry = viewModel.loadImageData
    
    viewModel.onImageLoad = { [weak cell] image in
      cell?.feedImageView.image = image
    }
    
    viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
      cell?.feedImageContainer.isShimmering = isLoading
    }
    
    viewModel.onRetryStateChange = { [weak cell] shouldRetry in
      cell?.feedImageRetryButton.isHidden = !shouldRetry
    }
    
    return cell
  }
  
  func preload() {
    viewModel.loadImageData()
  }
  
  func cancelLoad() {
    viewModel.cancelImageDataLoad()
  }
}
