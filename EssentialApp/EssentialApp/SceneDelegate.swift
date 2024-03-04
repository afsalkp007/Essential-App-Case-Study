//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Afsal on 21/02/2024.
//

import UIKit
import CoreData
import Combine
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  private lazy var httpClient: HTTPClient = {
    URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
  }()
  
  private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!

  private lazy var navigationController = UINavigationController(
      rootViewController: FeedUIComposer.feedComposedWith(
          feedLoader: makeRemoteFeedLoaderWithLocalFallback,
          imageLoader: makeLocalImageLoaderWithRemoteFallback,
          selection: showComments))

  private lazy var store: FeedStore & FeedImageDataStore = {
    try! CoreDataFeedStore(
      storeURL: NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite"))
  }()
  
  private lazy var localFeedLoader: LocalFeedLoader = {
    LocalFeedLoader(store: store, currentDate: Date.init)
  }()

  convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
    self.init()
    self.httpClient = httpClient
    self.store = store
  }
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else { return }
    
    window = UIWindow(windowScene: scene)
    window?.windowScene = scene
    configureWindow()

  }
  
  func configureWindow() {
    
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    localFeedLoader.validateCache { _ in }
  }
  
  private func showComments(for image: FeedImage) {
      let url = baseURL.appendingPathComponent("/v1/image/\(image.id)/comments")
      let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
      navigationController.pushViewController(comments, animated: true)
  }

  private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
      return { [httpClient] in
          return httpClient
              .getPublisher(url: url)
              .tryMap(ImageCommentsMapper.map)
              .eraseToAnyPublisher()
      }
  }
  
  private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error> {
    let remoteURL = baseURL.appendingPathComponent("/v1/feed")

    return httpClient
      .getPublisher(url: remoteURL)
      .tryMap(FeedItemsMapper.map)
      .caching(to: localFeedLoader)
      .fallback(to: localFeedLoader.loadPublisher)
  }
   
  private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
      let localImageLoader = LocalFeedImageDataLoader(store: store)

      return localImageLoader
          .loadImageDataPublisher(from: url)
          .fallback(to: { [httpClient] in
              httpClient
                  .getPublisher(url: url)
                  .tryMap(FeedImageDataMapper.map)
                  .caching(to: localImageLoader, using: url)
          })
  }
}

public extension HTTPClient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>

    func getPublisher(url: URL) -> Publisher {
        var task: HTTPClientTask?

        return Deferred {
            Future { completion in
                task = self.get(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>

    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: FeedImageDataLoaderTask?

        return Deferred {
            Future { completion in
                task = self.loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data, for: url)
        }).eraseToAnyPublisher()
    }
}

private extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}

public extension LocalFeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Error>

    func loadPublisher() -> Publisher {
        Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == [FeedImage] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {

    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
      ImmediateWhenOnMainQueueScheduler.shared
    }

    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: SchedulerTimeType {
            DispatchQueue.main.now
        }

        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
      
      static let shared = Self()

      private static let key = DispatchSpecificKey<UInt8>()
      private static let value = UInt8.max

      private init() {
          DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
      }

      private func isMainQueue() -> Bool {
          DispatchQueue.getSpecific(key: Self.key) == Self.value
      }

        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
          guard isMainQueue() else {
                return DispatchQueue.main.schedule(options: options, action)
            }

            action()
        }

        func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }

        func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}
