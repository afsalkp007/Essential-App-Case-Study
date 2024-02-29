//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 15/02/2024.
//

import UIKit
import EssentialFeed

public protocol FeedViewControllerDelegate {
  func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, FeedErrorView {
  public var delegate: FeedViewControllerDelegate?
  
  @IBOutlet private(set) public var errorView: ErrorView?
  
  private var loadingControllers = [IndexPath: FeedImageCellController]()
  
  private var tableModel = [FeedImageCellController]() {
    didSet { tableView.reloadData() }
  }
  
  private var onViewIsAppearing: ((FeedViewController) -> Void)?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    onViewIsAppearing = { vc in
      vc.onViewIsAppearing = nil
      vc.refreshControl?.beginRefreshing()
    }

    refresh()
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    tableView.sizeTableHeaderToFit()
  }
  
  public func display(_ cellControllers: [FeedImageCellController]) {
    loadingControllers = [:]
    tableModel = cellControllers
  }
  
  public func display(_ viewModel: FeedErrorViewModel) {
    errorView?.message = viewModel.message
  }
  
  @IBAction private func refresh() {
    delegate?.didRequestFeedRefresh()
  }

  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)

    onViewIsAppearing?(self)
  }
  
  public func display(_ viewModel: ResourceLoadingViewModel) {
    refreshControl?.update(isRefreshing: viewModel.isLoading)
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return cellController(forRowAt: indexPath).view(in: tableView)
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
    let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
  }
  
  private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
    loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
  }

}

extension UIRefreshControl {
  func update(isRefreshing: Bool) {
    if isRefreshing {
      beginRefreshing()
    } else {
      endRefreshing()
    }

  }
}
 
