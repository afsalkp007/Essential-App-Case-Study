//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Afsal on 08/02/2024.
//

import Foundation

func anyNSError() -> NSError {
  return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
  return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
  return Data("any data".utf8)
}

extension Date {
  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
  
  func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
      return calendar.date(byAdding: .minute, value: minutes, to: self)!
  }

  func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
      return calendar.date(byAdding: .day, value: days, to: self)!
  }
}


