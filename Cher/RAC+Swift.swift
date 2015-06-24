//
//  RAC+Swift.swift
//  Cher
//
//  Created by Zachary Davison on 6/23/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Foundation
import ReactiveCocoa

extension RACSignal {
  class func rac_return(object: AnyObject) -> RACSignal{
    return RACSignal.createSignal{
      (subscriber) in
      subscriber.sendNext(object)
      subscriber.sendCompleted()
      
      return RACDisposable()
    }
  }
}