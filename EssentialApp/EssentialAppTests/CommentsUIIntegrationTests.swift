//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Afsal on 04/03/2024.
//

import XCTest
import Combine
import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialApp

class CommentsUIIntegrationTests: XCTestCase {
  func test_commentsView_hasTitle() {
    let (sut, _) = makeSUT()

    sut.simulateAppearance()

    XCTAssertEqual(sut.title, commentsTitle)
  }
  
  func test_loadCommentsActions_requestCommentsFromLoader() {
    let (sut, loader) = makeSUT()
    XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")

    sut.simulateAppearance()
    XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")

    sut.simulateUserInitiatedReload()
    XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a reload")

    sut.simulateUserInitiatedReload()
    XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")

  }
  
  func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
    let (sut, loader) = makeSUT()

    sut.simulateAppearance()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

    loader.completeCommentsLoading(at: 0)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

    sut.simulateUserInitiatedReload()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

    loader.completeCommentsLoadingWithError(at: 1)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
  }

  func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
    let comment0 = makeComment(message: "a message", username: "a username")
    let comment1 = makeComment(message: "another message", username: "another username")
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    assertThat(sut, isRendering: [ImageComment]())

    loader.completeCommentsLoading(with: [comment0], at: 0)
    assertThat(sut, isRendering: [comment0])

    sut.simulateUserInitiatedReload()
    loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
    assertThat(sut, isRendering: [comment0, comment1])
  }
  
  func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyComments() {
      let comment = makeComment()
      let (sut, loader) = makeSUT()

      sut.loadViewIfNeeded()
      loader.completeCommentsLoading(with: [comment], at: 0)
      assertThat(sut, isRendering: [comment])

      sut.simulateUserInitiatedReload()
      loader.completeCommentsLoading(with: [], at: 1)
      assertThat(sut, isRendering: [ImageComment]())
  }
  
  func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
    let comment = makeComment()
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeCommentsLoading(with: [comment], at: 0)
    assertThat(sut, isRendering: [comment])

    sut.simulateUserInitiatedReload()
    loader.completeCommentsLoadingWithError(at: 1)
    assertThat(sut, isRendering: [comment])
  }
  
  func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()

    let exp = expectation(description: "Wait for background queue")
    DispatchQueue.global().async {
      loader.completeCommentsLoading(at: 0)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
    let (sut, loader) = makeSUT()
    
    sut.simulateAppearance()
    XCTAssertEqual(sut.errorMessage, nil)
    
    loader.completeCommentsLoadingWithError(at: 0)
    XCTAssertEqual(sut.errorMessage, loadError)
    
    sut.simulateUserInitiatedReload()
    XCTAssertEqual(sut.errorMessage, nil)
  }
  
  func test_tapOnErrorView_hidesErrorMessage() {
      let (sut, loader) = makeSUT()

      sut.loadViewIfNeeded()
      XCTAssertEqual(sut.errorMessage, nil)

      loader.completeCommentsLoadingWithError(at: 0)
      XCTAssertEqual(sut.errorMessage, loadError)

      sut.simulateErrorViewTap()
      XCTAssertEqual(sut.errorMessage, nil)
  }

  // MARK: - Helpers
  
  var commentsTitle: String {
    ImageCommentsPresenter.title
  }
  
  var loadError: String {
    LoadResourcePresenter<Any, DummyView>.loadError
  }
  
  private struct DummyView: ResourceView {
    func display(_ viewModel: Any) {}
  }
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, loader)
  }
  
  private func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
    return ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
  }
  
  private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
      XCTAssertEqual(sut.numberOfRenderedComments(), comments.count, "comments count", file: file, line: line)

      let viewModel = ImageCommentsPresenter.map(comments)

      viewModel.comments.enumerated().forEach { index, comment in
          XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
          XCTAssertEqual(sut.commentDate(at: index), comment.date, "date at \(index)", file: file, line: line)
          XCTAssertEqual(sut.commentUsername(at: index), comment.username, "username at \(index)", file: file, line: line)
      }
  }

  private class LoaderSpy {
    // MARK: - FeedLoader
    
    private var requests = [PassthroughSubject<[ImageComment], Error>]()
    
    var loadCommentsCallCount: Int {
      return requests.count
    }
    
    func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
      let publisher = PassthroughSubject<[ImageComment], Error>()
      requests.append(publisher)
      return publisher.eraseToAnyPublisher()
    }
    
    func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
      requests[index].send(comments)
    }
    
    func completeCommentsLoadingWithError(at index: Int = 0) {
      let error = NSError(domain: "an error", code: 0)
      requests[index].send(completion: (.failure(error)))
    }
  }
}

extension ListViewController {
    func numberOfRenderedComments() -> Int {
        tableView.numberOfSections == 0 ? 0 :  tableView.numberOfRows(inSection: commentsSection)
    }

    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }

    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }

    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }

    private func commentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedComments() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
    }

    private var commentsSection: Int {
        return 0
    }
}




