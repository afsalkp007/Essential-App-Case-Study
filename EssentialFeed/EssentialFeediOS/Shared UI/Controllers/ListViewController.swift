//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 15/02/2024.
//

import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
  
  private(set) public var errorView = ErrorView()
  
  public var onRefresh: (() -> Void)?
  
  private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
      .init(tableView: tableView) { (tableView, index, controller) in
          controller.dataSource.tableView(tableView, cellForRowAt: index)
      }
  }()

  private var onViewIsAppearing: ((ListViewController) -> Void)?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    onViewIsAppearing = { vc in
      vc.onViewIsAppearing = nil
      vc.refreshControl?.beginRefreshing()
    }

    configureTableView()
    configureTraitCollectionObservers()
    refresh()
  }
  
  private func configureTraitCollectionObservers() {
    registerForTraitChanges(
      [UITraitPreferredContentSizeCategory.self]
    ) { (self: Self, previous: UITraitCollection) in
      self.tableView.reloadData()
    }
  }
  
  private func configureTableView() {
      dataSource.defaultRowAnimation = .fade
      tableView.dataSource = dataSource
      tableView.tableHeaderView = errorView.makeContainer()

      errorView.onHide = { [weak self] in
          self?.tableView.beginUpdates()
          self?.tableView.sizeTableHeaderToFit()
          self?.tableView.endUpdates()
      }
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    tableView.sizeTableHeaderToFit()
  }
  
  public func display(_ cellControllers: [CellController]) {
    var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
    snapshot.appendSections([0])
    snapshot.appendItems(cellControllers, toSection: 0)
    dataSource.apply(snapshot)
  }
  
  public func display(_ viewModel: ResourceErrorViewModel) {
    errorView.message = viewModel.message
  }
  
  @IBAction private func refresh() {
    onRefresh?()
  }

  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)

    onViewIsAppearing?(self)
  }
  
  public func display(_ viewModel: ResourceLoadingViewModel) {
    refreshControl?.update(isRefreshing: viewModel.isLoading)
  }
  
  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let dl = cellController(at: indexPath)?.delegate
      dl?.tableView?(tableView, didSelectRowAt: indexPath)
  }
  
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let dl = cellController(at: indexPath)?.delegate
    dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
  }
  
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      let dsp = cellController(at: indexPath)?.dataSourcePrefetching
      dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
  }

  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      let dsp = cellController(at: indexPath)?.dataSourcePrefetching
      dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
  }
  
  private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
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
 
