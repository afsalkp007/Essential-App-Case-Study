//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Afsal on 14/02/2024.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UITableViewController {
  private var loader: FeedLoader?
  
  private var onViewIsAppearing: ((FeedViewController) -> Void)?

  convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
  }
  
  override func viewDidLoad() {
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
 
final class FeedViewControllerTests: XCTestCase {
  
  func test_init_doesNotLoadFeed() {
    let (_, loader) = makeSUT()

    XCTAssertEqual(loader.loadCallCount, 0)
  }
  
  func test_viewDidLoad_loadsFeed() {
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    
    XCTAssertEqual(loader.loadCallCount, 1)
  }
  
  func test_userInitiatedFeedReload_reloadsFeed() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()

    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadCallCount, 2)
    
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadCallCount, 3)

  }
  
  func test_viewDidLoad_showsLoadingIndicator() {
    let (sut, _) = makeSUT()

    sut.simulateAppearance()
   
    XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
  }
  
  func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
    let (sut, loader) = makeSUT()

    sut.simulateAppearance()
    loader.completeFeedLoading()

    XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
  }
  
  func test_userInitiatedFeedReload_showsLoadingIndicator() {
    let (sut, _) = makeSUT()

    sut.simulateAppearance()
    sut.simulateUserInitiatedFeedReload()

    XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
  }
  
  func test_userInitiatedFeedReload_hidesLoadingIndicatorOnLoaderCompletion() {
    let (sut, loader) = makeSUT()

    
    sut.simulateUserInitiatedFeedReload()
    loader.completeFeedLoading()

    XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
  }

  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, loader)
  }


  class LoaderSpy: FeedLoader {
    private var completions = [(FeedLoader.Result) -> Void]()
    var loadCallCount: Int {
      return completions.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      completions.append(completion)
    }

    func completeFeedLoading() {
       completions[0](.success([]))
    }
  }
}

private extension FeedViewController {
  func simulateUserInitiatedFeedReload() {
    refreshControl?.simulatePullToRefresh()
  }
}


private extension FeedViewController {
  func simulateAppearance() {
    if !isViewLoaded {
      loadViewIfNeeded()
      prepareForFirstAppearance()
    }
    beginAppearanceTransition(true, animated: false)
    endAppearanceTransition()
  }
  
  private func prepareForFirstAppearance() {
    setSmallFrameToPreventRenderingCells()
    replaceRefreshControlWithFakeForiOS17PlusSupport()
  }

  private func setSmallFrameToPreventRenderingCells() {
    tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
  }

  private func replaceRefreshControlWithFakeForiOS17PlusSupport() {
    let fakeRefreshControl = FakeUIRefreshControl()

    refreshControl?.allTargets.forEach { target in
      refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
        fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
      }
    }

    refreshControl = fakeRefreshControl
  }

}

private class FakeUIRefreshControl: UIRefreshControl {
  private var _isRefreshing = false
  
  override var isRefreshing: Bool { _isRefreshing }

  override func beginRefreshing() {
    _isRefreshing = true
  }

  override func endRefreshing() {
    _isRefreshing = false
  }
}

private extension UIRefreshControl {
  func simulatePullToRefresh() {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    }
  }
}

