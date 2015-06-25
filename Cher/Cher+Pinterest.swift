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
  
  private let _pinterest: Pinterest
  
  public init(clientID: String){
    self._pinterest = Pinterest(clientId: clientID)
  }
  
  public func share(item: Item) -> RACSignal {
    
    if(_pinterest.canPinWithSDK() == false){
      let error = NSError(domain: "com.drop.cher.pinterest.unavailable", code: 404, userInfo: nil)
      return RACSignal.error(error)
    }
    
    _pinterest.createPinWithImageURL(
      NSURL(string: "http://placekitten.com.s3.amazonaws.com/homepage-samples/408/287.jpg"),
      sourceURL: NSURL(string: "http://getdrop.com"),
      description: "test")
    
    return RACSignal.empty()
  }
}