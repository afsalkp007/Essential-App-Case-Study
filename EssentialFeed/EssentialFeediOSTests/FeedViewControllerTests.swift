//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Afsal on 14/02/2024.
//

import XCTest

final class FeedViewController {
  init(loader: FeedViewControllerTests.LoaderSpy) {

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
  }


}
