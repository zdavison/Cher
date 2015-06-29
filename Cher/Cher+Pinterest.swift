//
//  Cher+Instagram.swift
//  Cher
//
//  Created by Zachary Davison on 6/24/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Foundation
import ReactiveCocoa

public class PinterestItem : Item {
  
  public let imageURL:  NSURL
  public let sourceURL: NSURL
  
  public init(text: String?, imageURLString: String, sourceURLString: String) {
    self.imageURL  = NSURL(string: imageURLString)!
    self.sourceURL = NSURL(string: sourceURLString)!
    super.init(text: text, image: nil)
  }
}

public class PinterestFlow : Flow {
  
  private let _pinterest: Pinterest
  
  public init(clientID: String){
    self._pinterest = Pinterest(clientId_fixed: clientID)
  }
  
  public func share(item: PinterestItem) -> RACSignal {
    
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