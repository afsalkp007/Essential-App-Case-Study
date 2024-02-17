//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Afsal on 18/02/2024.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
  var description: String?
  var location: String?
  let image: Image?
  let isLoading: Bool
  let shouldRetry: Bool
  
  var hasLocation: Bool {
    return location != nil
  }
}

protocol FeedImageView {
  associatedtype Image
  
  func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
  private let view: View
  private let imageTransformer: (Data) -> Image?
  
  init(view: View, imageTransformer: @escaping (Data) -> Image?) {
    self.view = view
    self.imageTransformer = imageTransformer
  }
  
  
  func didStartLoadingImageData(for model: FeedImage) {
    view.display(FeedImageViewModel(
      description: model.description,
      location: model.location,
      image: nil,
      isLoading: true,
      shouldRetry: false))
  }

  private struct InvalidImageDataError: Error {}

  func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
    guard let image = imageTransformer(data) else {
      return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
    }

    view.display(FeedImageViewModel(
      description: model.description,
      location: model.location,
      image: image,
      isLoading: false,
      shouldRetry: false))
  }

  func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
    view.display(FeedImageViewModel(
      description: model.description,
      location: model.location,
      image: nil,
      isLoading: false,
      shouldRetry: true))
  }
}

