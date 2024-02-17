//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by Afsal on 17/02/2024.
//

import UIKit
import EssentialFeed

final class FeedImageCellViewModel {
  typealias Observer<T> = (T) -> Void
  
  private var task: FeedImageDataLoaderTask?
  private let model: FeedImage
  private let imageLoader: FeedImageDataLoader
  
  init(model: FeedImage, imageLoader: FeedImageDataLoader) {
    self.model = model
    self.imageLoader = imageLoader
  }

  var location: String? {
    return model.location
  }
  
  var hasLocation: Bool {
    return location != nil
  }
  
  var description: String? {
    return model.description
  }
  
  var onImageLoad: Observer<UIImage?>?
  var onImageLoadingStateChange: Observer<Bool>?
  var onRetryStateChange: Observer<Bool>?
  
  func loadImageData() {
    onImageLoadingStateChange?(true)
    onRetryStateChange?(false)
    task = imageLoader.loadImageData(from: self.model.url) { [weak self] result in
      self?.handle(result)
    }
  }
  
  private func handle(_ result: FeedImageDataLoader.Result) {
    if let image = (try? result.get()).flatMap(UIImage.init) {
      onImageLoad?(image)
    } else {
      onRetryStateChange?(true)
    }
    onImageLoadingStateChange?(false)
  }
  
  func cancelImageDataLoad() {
    task?.cancel()
    task = nil
  }
}

