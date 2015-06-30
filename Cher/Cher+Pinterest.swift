//
//  Cher+Instagram.swift
//  Cher
//
//  Created by Zachary Davison on 6/24/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Foundation
import ReactiveCocoa

public class PinterestFlow : Flow {
  
  public struct Input {
    let imageURL:   NSURL
    let sourceURL:  NSURL
    let text:       String
    
    public init(imageURL: NSURL, sourceURL: NSURL, text: String){
      self.imageURL   = imageURL
      self.sourceURL  = sourceURL
      self.text       = text
    }
  }
  
  private let _pinterest: Pinterest
  
  public init(clientID: String){
    self._pinterest = Pinterest(clientId_fixed: clientID)
  }
  
  public static func available() -> Bool {
    return true
  }
  
  public func share(item: Input) -> RACSignal {
    
    return RACSignal.createSignal{
      (subscriber) in
      
      let disposable = RACDisposable()
      
      self._pinterest.createPinWithImageURL(
        item.imageURL,
        sourceURL: item.sourceURL,
        description: item.text)
      
      subscriber.sendCompleted()
      
      return disposable
    }
    .replayLast()
  }
}