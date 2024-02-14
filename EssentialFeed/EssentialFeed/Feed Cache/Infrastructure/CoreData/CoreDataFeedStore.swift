//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Afsal on 12/02/2024.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
  private let container: NSPersistentContainer
  private let context: NSManagedObjectContext

  public init(storeURL: URL, bundle: Bundle = .main) throws {
    container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
    context = container.newBackgroundContext()
  }


  public func retrieve(completion: @escaping RetrievalCompletion) {
    perform { context in
      completion(Result {
        try ManagedCache.find(in: context).map { cache in
          CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)
        }
      })
    }
  }

  public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    perform { context in
      completion(Result {
        let managedCache = try ManagedCache.newUniqueInstance(in: context)
        managedCache.timestamp = timestamp
        managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
        try context.save()
      })
    }

  }

  public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    perform { context in
      completion(Result {
        try ManagedCache.find(in: context).map(context.delete).map(context.save)
      })
    }
  }
  
  private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
    let context = self.context
    context.perform { action(context) }
  }

}
