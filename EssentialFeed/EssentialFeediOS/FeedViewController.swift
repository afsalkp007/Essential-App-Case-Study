//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 15/02/2024.
//

import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController {
  private var loader: FeedLoader?
  
  private var onViewIsAppearing: ((FeedViewController) -> Void)?

  public convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()

    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    
    onViewIsAppearing = { vc in
      vc.onViewIsAppearing = nil
      vc.refresh()
    }

    load()
  }
  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)

    onViewIsAppearing?(self)
  }

  
  private func refresh() {
    refreshControl?.beginRefreshing()
  }

  @objc private func load() {
    refreshControl?.beginRefreshing()
    loader?.load { [weak self] _ in
      self?.refreshControl?.endRefreshing()
    }
  }

}
 
