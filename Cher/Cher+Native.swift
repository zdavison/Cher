//
//  Cher+SocialFramework.swift
//  Cher
//
//  Created by Zachary Davison on 6/23/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Social
import Accounts

typealias Parameters = [String : AnyObject]

// MARK: - Flow -

// MARK: Facebook
public class FacebookFlow : NativeFlow {
  public init(){
    super.init(serviceType: SLServiceTypeFacebook)
  }
}

// MARK: Twitter
public class TwitterFlow : NativeFlow {
  public init(){
    super.init(serviceType: SLServiceTypeTwitter)
  }
}

// MARK: Native
public class NativeFlow : Flow {
  
  private let _serviceType: String
  
  private init(serviceType: String){
    self._serviceType = serviceType
  }
  
  public func share(item: Item) -> RACSignal {
    
    let serviceType = _serviceType
    
    return RACSignal.createSignal({
      (subscriber: RACSubscriber!) -> RACDisposable! in
      
      let composeViewController = SLComposeViewController(forServiceType: serviceType)
      let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
      
      // Configure the composeViewController
      if let text = item.text {
        composeViewController.setInitialText(text)
      }
      if let image = item.image {
        composeViewController.addImage(image)
      }
      
      // Set our completion handler
      composeViewController.completionHandler = {
        (result: SLComposeViewControllerResult) in
        switch(result){
        case .Done:
          subscriber.sendCompleted()
        case .Cancelled:
          let error = NSError(domain: kCherErrorDomain, code: ErrorCode.User.rawValue, userInfo: [NSLocalizedDescriptionKey: "User cancelled share."])
          subscriber.sendError(error)
        }
      }
      
      // Present
      rootViewController?.presentViewController(composeViewController, animated: true, completion: nil)
      
      return RACDisposable(){
        composeViewController.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
      }
    })
  }
}