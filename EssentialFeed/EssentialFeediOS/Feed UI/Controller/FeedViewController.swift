//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 15/02/2024.
//

import UIKit

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
  public var refreshController: FeedRefreshController?
  var tableModel = [FeedImageCellController]() {
    didSet { tableView.reloadData() }
  }
  
  private var onViewIsAppearing: ((FeedViewController) -> Void)?

  convenience init(refreshController: FeedRefreshController) {
    self.init()
    self.refreshController = refreshController
    
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()

    refreshControl = refreshController?.view
    tableView.prefetchDataSource = self
    
    onViewIsAppearing = { vc in
      vc.onViewIsAppearing = nil
      vc.refreshControl?.beginRefreshing()
    }

    refreshController?.load()
  }
  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)

    onViewIsAppearing?(self)
  }

  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return cellController(forRowAt: indexPath).view()
  }

  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cancelCellControllerLoad(forRowAt: indexPath)
  }
  
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      cellController(forRowAt: indexPath).preload()
    }
  }

  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(cancelCellControllerLoad)
  }
  
  private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
    return tableModel[indexPath.row]
  }
  
  private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
    cellController(forRowAt: indexPath).cancelLoad()
  }

}
 