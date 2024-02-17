//
//  FeedRefreshController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 16/02/2024.
//

import UIKit

public final class FeedRefreshController: NSObject {
  public lazy var view: UIRefreshControl = binded(UIRefreshControl())
  
  private let viewModel: FeedViewModel
  
  init(feedViewModel: FeedViewModel) {
    self.viewModel = feedViewModel
  }
    
  @objc func load() {
    viewModel.loadFeed()
  }
  
  private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
    viewModel.onLoadingStateChange = { [weak self] isLoading in
      if isLoading {
        self?.view.beginRefreshing()
      } else {
        self?.view.endRefreshing()
      }
    }
    view.addTarget(self, action: #selector(load), for: .valueChanged)
    return view
  }
}
