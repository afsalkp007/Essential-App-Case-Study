//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Afsal on 20/02/2024.
//

import Foundation

extension HTTPURLResponse {
  private static var OK_200 = 200
  
  var isOK: Bool {
    return statusCode == Self.OK_200
  }
}
