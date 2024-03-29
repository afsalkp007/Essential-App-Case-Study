//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Afsal on 12/02/2024.
//

import CoreData

@objc(ManagedCache)
internal class ManagedCache: NSManagedObject {
  @NSManaged var timestamp: Date
  @NSManaged var feed: NSOrderedSet
}

extension ManagedCache {
  internal static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
    let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
    request.returnsObjectsAsFaults = false
    return try context.fetch(request).first
  }
  
  static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
    try find(in: context).map(context.delete)
    let managedCache = ManagedCache(context: context)
    return managedCache
  }
  
  var localFeed: [LocalFeedImage] {
    return feed
      .compactMap { ($0 as? ManagedFeedImage)?.local }
  }
}
