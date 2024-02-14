//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Afsal on 14/02/2024.
//

import XCTest
import UIKit

final class FeedViewController: UIViewController {
  private var loader: FeedViewControllerTests.LoaderSpy?
  
  convenience init(loader: FeedViewControllerTests.LoaderSpy) {
    self.init()
    self.loader = loader
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    loader?.load()
  }

}

final class FeedViewControllerTests: XCTestCase {
  
  func test_init_doesNotLoadFeed() {
    let loader = LoaderSpy()
    _ = FeedViewController(loader: loader)

    XCTAssertEqual(loader.loadCallCount, 0)
  }
  
  // MARK: - Helpers

  class LoaderSpy {
    private(set) var loadCallCount: Int = 0
    
    func load() {
      loadCallCount += 1
    }

  }


}
