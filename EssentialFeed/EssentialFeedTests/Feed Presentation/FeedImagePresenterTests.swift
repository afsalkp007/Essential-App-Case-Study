//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 19/02/2024.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
  
  func test_init_doesNotSendMessageToView() {
    let (_, view) = makeSUT()
    
    XCTAssertTrue(view.messages.isEmpty)
  }
  
  func test_didStartLoadingImageData_loadingImage() {
    let (sut, view) = makeSUT()
    let image = uniqueImage()

    sut.didStartLoadingImageData(for: image)
    
    let model = view.messages.first
    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(model?.description, image.description)
    XCTAssertEqual(model?.location, image.location)
    XCTAssertEqual(model?.isLoading, true)
    XCTAssertEqual(model?.shouldRetry, false)
  }
  
  func test_didFinishLoadingImageData_showRetryForFailedImageTransformation() {
    let (sut, view) = makeSUT(imageTransformer: fail)
    let image = uniqueImage()

    sut.didFinishLoadingImageData(with: Data(), for: image)
    
    let model = view.messages.first
    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(model?.description, image.description)
    XCTAssertEqual(model?.location, image.location)
    XCTAssertEqual(model?.isLoading, false)
    XCTAssertEqual(model?.shouldRetry, true)
    XCTAssertNil(model?.image)
  }
  
  func test_didFinishLoadingImageData_displayImageOnSuccessfulTransformation() {
    let image = uniqueImage()
    let transformedData = AnyImage()
    let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })

    sut.didFinishLoadingImageData(with: Data(), for: image)
    
    let model = view.messages.first
    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(model?.description, image.description)
    XCTAssertEqual(model?.location, image.location)
    XCTAssertEqual(model?.image, transformedData)
    XCTAssertEqual(model?.isLoading, false)
    XCTAssertEqual(model?.shouldRetry, false)

  }
  
  func test_didFinishLoadingImageDataWithError_displayRetry() {
    let (sut, view) = makeSUT(imageTransformer: fail)
    let image = uniqueImage()

    sut.didFinishLoadingImageData(with: anyNSError(), for: image)
    
    let model = view.messages.first
    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(model?.description, image.description)
    XCTAssertEqual(model?.location, image.location)
    XCTAssertEqual(model?.isLoading, false)
    XCTAssertEqual(model?.shouldRetry, true)
    XCTAssertNil(model?.image)
  }
  
  
  // MARK: - Helpers
  
  private struct AnyImage: Equatable {}
  
  private func makeSUT(
    imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
    file: StaticString = #filePath,
    line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }
  
  private var fail: (Data) -> AnyImage? {
    return { _ in nil }
  }
  
  private class ViewSpy: FeedImageView {
    private(set) var messages = [FeedImageViewModel<AnyImage>]()
    
    func display(_ viewModel: FeedImageViewModel<AnyImage>) {
      messages.append(viewModel)
    }
  }
}
