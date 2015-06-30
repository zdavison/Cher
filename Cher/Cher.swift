//
//  Cher.swift
//  Cher
//
//  Created by Zachary Davison on 6/23/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Foundation
import ReactiveCocoa

public let kCherErrorDomain = "com.thingsdoer.cher"

internal enum ErrorCode : Int{
  case BadData   = 400
  case User      = 418
  case NotFound  = 404
  case Unknown   = 666
}

private extension String {
  func findURLs() -> [NSURL] {
    var error: NSError?
    let dataDetector = NSDataDetector(types: NSTextCheckingType.Link.rawValue, error: &error)
    let results = dataDetector?.matchesInString(
      self,
      options: NSMatchingOptions.allZeros,
      range: NSMakeRange(0, count(self))
    )
    
    if let e = error{
      return []
    }
    
    let textCheckingResults = results as! [NSTextCheckingResult]
    
    return textCheckingResults.map{
      let substring = NSString(string: self).substringWithRange($0.range)
      return NSURL(string: substring)!
    }
  }
}

//MARK: Item
public class Item {
  
  public let text:       String?
  public let image:      UIImage?
  public let URLs:       [NSURL]
  
  public init(text: String? = nil, image: UIImage? = nil, urls: [NSURL]? = nil){
    self.text  = text
    self.image = image
    self.URLs  = urls ?? text?.findURLs() ?? []
  }
}

// MARK: Flow
public protocol Flow {
  typealias Input
  
  static func available() -> Bool
  
  func share(item: Input) -> RACSignal // Completed | Error
}