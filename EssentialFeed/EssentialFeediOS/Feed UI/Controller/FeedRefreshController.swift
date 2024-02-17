//
//  FeedRefreshController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 16/02/2024.
//

import UIKit

protocol FeedRefreshControllerDelegate {
  func didRequestFeedRefresh()
}

public final class FeedRefreshController: NSObject, FeedLoadingView {
  public lazy var view = loadView()
  
  private let delegate: FeedRefreshControllerDelegate
  
  init(delegate: FeedRefreshControllerDelegate) {
    self.delegate = delegate
  }
    
  @objc func load() {
    delegate.didRequestFeedRefresh()
  }
  
  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view.beginRefreshing()
    } else {
      view.endRefreshing()
    }

  }
  
  private func loadView() -> UIRefreshControl {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(load), for: .valueChanged)
    return view
  }
}
