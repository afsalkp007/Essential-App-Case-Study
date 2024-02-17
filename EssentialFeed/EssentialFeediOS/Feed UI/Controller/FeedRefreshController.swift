//
//  FeedRefreshController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 16/02/2024.
//

import UIKit

public final class FeedRefreshController: NSObject, FeedLoadingView {
  public lazy var view = loadView()
  
  private let presenter: FeedPresenter
  
  init(presenter: FeedPresenter) {
    self.presenter = presenter
  }
    
  @objc func load() {
    presenter.loadFeed()
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
