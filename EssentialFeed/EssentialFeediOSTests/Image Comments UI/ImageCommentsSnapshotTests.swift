//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Afsal on 01/03/2024.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {

    func test_listWithComments() {
        let sut = makeSUT()

        sut.display(comments())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
      assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
    }

    // MARK: - Helpers

    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
  
  private func comments() -> [CellController] {
    commentControllers().map { CellController($0) }
  }

    private func commentControllers() -> [ImageCommentCellController] {
        return [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    username: "a long long long long username"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "East Side Gallery\nMemorial in Berlin, Germany",
                    date: "10 days ago",
                    username: "a username"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "nice",
                    date: "1 hour ago",
                    username: "a."
                )
            ),
        ]
    }
  
  private func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
    let snapshotURL = makeSnapshotURL(named: name, file: file)
    let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

    guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
      XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
      return
    }

    if snapshotData != storedSnapshotData {
      let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent(snapshotURL.lastPathComponent)

      try? snapshotData?.write(to: temporarySnapshotURL)

      XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
    }
  }
  
  private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
    let snapshotURL = makeSnapshotURL(named: name, file: file)
    let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

    do {
      try FileManager.default.createDirectory(
        at: snapshotURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )

      try snapshotData?.write(to: snapshotURL)
      XCTFail("Record succeeded - use `assert` to compare the snapshot from now on.", file: file, line: line)
    } catch {
      XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
    }
  }
  
  private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
    return URL(fileURLWithPath: String(describing: file))
      .deletingLastPathComponent()
      .appendingPathComponent("snapshots")
      .appendingPathComponent("\(name).png")
  }
  
  private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
    guard let data = snapshot.pngData() else {
      XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
      return nil
    }

    return data
  }

}
 
