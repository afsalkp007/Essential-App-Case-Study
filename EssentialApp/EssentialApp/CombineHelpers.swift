//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by Afsal on 04/03/2024.
//

import Foundation
import Combine
import EssentialFeed

public extension Paginated {
  init(items: [Item], loadMorePublisher: (() -> AnyPublisher<Self, Error>)?) {
      self.init(items: items, loadMore: loadMorePublisher.map { publisher in
          return { completion in
              publisher().subscribe(Subscribers.Sink(receiveCompletion: { result in
                  if case let .failure(error) = result {
                      completion(.failure(error))
                  }
              }, receiveValue: { result in
                  completion(.success(result))
              }))
          }
      })
  }

    var loadMorePublisher: (() -> AnyPublisher<Self, Error>)? {
        guard let loadMore = loadMore else { return nil }

        return {
            Deferred {
                Future(loadMore)
            }.eraseToAnyPublisher()
        }
    }
}

typealias AnyDispatchQueueScheduler = AnyScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>

extension AnyDispatchQueueScheduler {
  static var immediateOnMainQueue: Self {
    DispatchQueue.immediateWhenOnMainQueueScheduler.eraseToAnyScheduler()
  }
}

extension Scheduler {
  func eraseToAnyScheduler() -> AnyScheduler<SchedulerTimeType, SchedulerOptions> {
    AnyScheduler(self)
  }
}

struct AnyScheduler<SchedulerTimeType: Strideable, SchedulerOptions>: Scheduler where SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
  private let _now: () -> SchedulerTimeType
  private let _minimumTolerance: () -> SchedulerTimeType.Stride
  private let _schedule: (SchedulerOptions?, @escaping () -> Void) -> Void
  private let _scheduleAfter: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void) -> Void
  private let _scheduleAfterInterval: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void) -> Cancellable

  init<S>(_ scheduler: S) where SchedulerTimeType == S.SchedulerTimeType, SchedulerOptions == S.SchedulerOptions, S: Scheduler {
    _now = { scheduler.now }
    _minimumTolerance = { scheduler.minimumTolerance }
    _schedule = scheduler.schedule(options:_:)
    _scheduleAfter = scheduler.schedule(after:tolerance:options:_:)
    _scheduleAfterInterval = scheduler.schedule(after:interval:tolerance:options:_:)
  }

  var now: SchedulerTimeType { _now() }

  var minimumTolerance: SchedulerTimeType.Stride { _minimumTolerance() }

  func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
    _schedule(options, action)
  }

  func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
    _scheduleAfter(date, tolerance, options, action)
  }

  func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
    _scheduleAfterInterval(date, interval, tolerance, options, action)
  }
}

