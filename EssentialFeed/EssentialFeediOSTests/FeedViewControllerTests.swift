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
  private var loader: FeedViewControllerTests.LoaderSpy?
  
  convenience init(loader: FeedViewControllerTests.LoaderSpy) {
    self.init()
    self.loader = loader
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    load()
  }

  @objc private func load() {
    loader?.load { _ in }
  }

}
 
final class FeedViewControllerTests: XCTestCase {
  
  func test_init_doesNotLoadFeed() {
    let loader = LoaderSpy()
    _ = FeedViewController(loader: loader)

    XCTAssertEqual(loader.loadCallCount, 0)
  }
  
  func test_viewDidLoad_loadsFeed() {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)
    
    sut.loadViewIfNeeded()
    
    XCTAssertEqual(loader.loadCallCount, 1)
  }
  
  func test_pullToRefresh_loadsFeed() {
    let (sut, loader) = makeSUT()
    sut.loadViewIfNeeded()

    sut.refreshControl?.allTargets.forEach { target in
      sut.refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    }

    XCTAssertEqual(loader.loadCallCount, 2)
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
    
    private(set) var loadCallCount: Int = 0
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      loadCallCount += 1
    }

  }


}
