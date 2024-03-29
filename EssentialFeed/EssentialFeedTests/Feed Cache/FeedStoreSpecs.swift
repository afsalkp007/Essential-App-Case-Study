//
//  FeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by Afsal on 11/02/2024.
//

import Foundation
import EssentialFeed

protocol FeedStoreSpecs {
  func test_retrieve_deliversEmptyOnEmptyCache()
  func test_retrieve_hasNoSideEffectsOnEmptyCache()
  func test_retrieve_deliversFoundValuesOnNonEmptyCache()
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache()

  func test_insert_deliversNoErrorOnEmptyCache()
  func test_insert_deliversNoErrorOnNonEmptyCache()
  func test_insert_overridesPreviouslyInsertedCacheValues()
  
  func test_delete_deliversNoErrorOnEmptyCache()
  func test_delete_hasNoSideEffectsOnEmptyCache()
  func test_delete_deliversNoErrorOnNonEmptyCache()
  func test_delete_emptiesPreviouslyInsertedCache()

  func test_storeSideEffects_runSerially()

}

protocol FailureRetrieveFeedStoreSpecs: FeedStoreSpecs {
  func test_retrieve_deliversFailureOnRetrievalError()
  func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailureInsertFeedStoreSpecs: FeedStoreSpecs {
  func test_insert_deliversErrorOnInsertionError()
  func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailureDeleteFeedStoreSpecs: FeedStoreSpecs {
  func test_delete_deliversErrorOnDeletionError()
  func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStore = FailureRetrieveFeedStoreSpecs & FailureInsertFeedStoreSpecs & FailureDeleteFeedStoreSpecs
