//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by Afsal on 17/02/2024.
//

//import UIKit
import Foundation
import EssentialFeed

final class FeedImageCellViewModel<Image> {
  typealias Observer<T> = (T) -> Void
  
  private var task: FeedImageDataLoaderTask?
  private let model: FeedImage
  private let imageLoader: FeedImageDataLoader
  private let imageTransformer: (Data) -> Image?
  
  init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
    self.model = model
    self.imageLoader = imageLoader
    self.imageTransformer = imageTransformer
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
  
  var onImageLoad: Observer<Image>?
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
    if let image = (try? result.get()).flatMap(imageTransformer) {
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

