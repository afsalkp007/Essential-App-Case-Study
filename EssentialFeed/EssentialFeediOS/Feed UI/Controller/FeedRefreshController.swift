//
//  FeedRefreshController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 16/02/2024.
//

import UIKit
import EssentialFeed

final public class FeedRefreshController: NSObject {
  public lazy var view: UIRefreshControl = {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(load), for: .valueChanged)
    return view
  }()
  
  private let feedLoader: FeedLoader
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  var onRefresh: (([FeedImage]) -> Void)?
  
  @objc func load() {
    view.beginRefreshing()
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.onRefresh?(feed)
      }
      self?.view.endRefreshing()
    }
  }
}
