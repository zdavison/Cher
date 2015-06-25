//
//  Cher.swift
//  Cher
//
//  Created by Zachary Davison on 6/23/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Foundation
import ReactiveCocoa

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
  
  public init(text: String? = nil, image: UIImage? = nil){
    self.text  = text
    self.image = image
    self.URLs  = text?.findURLs() ?? []
  }
  
  public func via(flow: Flow) -> RACSignal {
    return flow.share(self)
  }
  
  public func to
    <D: Destination, I: Interface where D.Input == I.Output>
    (destination: D, using interface: I) -> RACSignal {
    return interface.present(self).flattenMap{
      (object: AnyObject!) -> RACStream! in
      return destination.share(object as! D.Input) ?? RACSignal.empty()
    }
  }
  
  public func to
    <D: Destination where D.Input == Item>
    (destination: D) -> RACSignal{
      return destination.share(self)
  }
}

//MARK: Destination
public protocol Destination {
  typealias Input
  func share(input: Input) -> RACSignal // Completed | Error
}

//MARK: Interface
public protocol Interface {
  typealias Output
  func present(item: Item) -> RACSignal //RACSignal<Output> | Error
}

// MARK: Flow
public protocol Flow {
  func share(item: Item) -> RACSignal // Completed | Error
}

//MARK: Cher
public class Cher {
  public class func url(urlString: String) -> Item {
    return Item(text: urlString)
  }
  public class func text(text: String) -> Item {
    return Item(text: text)
  }
  public class func image(image: UIImage) -> Item {
    return Item(text: nil, image: image)
  }
}