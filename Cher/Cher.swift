//
//  Cher.swift
//  Cher
//
//  Created by Zachary Davison on 6/23/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Foundation
import ReactiveCocoa

//MARK: Item
public enum Item {
  
  case URL(URL: NSURL)
  case Text(string: String)
  case Image(image: UIImage)
  
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
    return Item.URL(URL: NSURL(string: urlString)!)
  }
  public class func text(text: String) -> Item {
    return Item.Text(string: text)
  }
  public class func image(image: UIImage) -> Item {
    return Item.Image(image: image)
  }
}