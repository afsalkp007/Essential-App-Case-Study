//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Afsal on 29/02/2024.
//

import Foundation

public final class ImageCommentsPresenter {
  public static var title: String {
    return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
      tableName: "ImageComments",
      bundle: Bundle(for: Self.self),
      comment: "Title for the image comments view")
  }
}
