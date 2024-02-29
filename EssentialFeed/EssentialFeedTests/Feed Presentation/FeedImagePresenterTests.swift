//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 19/02/2024.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
  
  func test_map_createsViewModel() {
    let image = uniqueImage()
    
    let viewModel = FeedImagePresenter.map(image)
    
    XCTAssertEqual(viewModel.description, image.description)
    XCTAssertEqual(viewModel.location, image.location)
  }
}
