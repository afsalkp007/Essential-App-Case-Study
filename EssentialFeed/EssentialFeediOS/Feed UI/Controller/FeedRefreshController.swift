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
  @IBOutlet public weak var view: UIRefreshControl?
  
  var delegate: FeedRefreshControllerDelegate?
    
  @IBAction func refresh() {
    delegate?.didRequestFeedRefresh()
  }
  
  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view?.beginRefreshing()
    } else {
      view?.endRefreshing()
    }

  }
}
