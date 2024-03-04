//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by Afsal on 04/03/2024.
//

import Combine
import EssentialFeed

public extension Paginated {
    var loadMorePublisher: (() -> AnyPublisher<Self, Error>)? {
        guard let loadMore = loadMore else { return nil }

        return {
            Deferred {
                Future(loadMore)
            }.eraseToAnyPublisher()
        }
    }
}
