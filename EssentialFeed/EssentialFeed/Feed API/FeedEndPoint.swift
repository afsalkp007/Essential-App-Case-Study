//
//  FeedEndPoint.swift
//  EssentialFeed
//
//  Created by Afsal on 04/03/2024.
//

import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
