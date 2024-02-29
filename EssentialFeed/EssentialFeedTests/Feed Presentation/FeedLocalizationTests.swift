//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Afsal on 18/02/2024.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {

  func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
    let table = "Feed"
    let bundle = Bundle(for: FeedPresenter.self)
    
    assertLocalizedKeyAndValuesExist(in: bundle, table)
  }
}
