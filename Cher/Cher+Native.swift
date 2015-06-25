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

// MARK: - Destination -

// MARK: Facebook
public class Facebook : Native {
  
  // -- Public
  public class var account: ACAccount? {
    let store = ACAccountStore()
    let type  = store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
    return store.accountsWithAccountType(type).first as? ACAccount
  }
  
  // -- Private
  private class func _requestFromInput(input: Input) -> SLRequest {
    
    var parameters = Parameters()
    
    if let url = input.URLs.first{
      parameters["link"] = url.absoluteString
    }
    if let text = input.text{
      parameters["message"] = text
    }
    
    return SLRequest(
      forServiceType: SLServiceTypeFacebook,
      requestMethod: .POST,
      URL: NSURL(string: "https://graph.facebook.com/me/feed"),
      parameters: nil)
  }
  
  // -- init
  public init(account: ACAccount){
    super.init(account: account, requestBuilder: Facebook._requestFromInput)
  }
}

// MARK: Twitter
public class Twitter : Native {
  
  // -- Public
  public class var accounts: [ACAccount] {
    let store = ACAccountStore()
    let type  = store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    return store.accountsWithAccountType(type) as! [ACAccount]
  }
  
  // -- Private
  private class func _requestFromInput(input: Input) -> SLRequest {
    
    var parameters = Parameters()
    if let text = input.text{
      parameters["message"] = text
    }
    
    return SLRequest(
      forServiceType: SLServiceTypeTwitter,
      requestMethod: .POST,
      URL: NSURL(string: "https://api.twitter.com/1.1/statuses/update.json"),
      parameters: parameters)
  }
  
  // -- init
  public init(account: ACAccount){
    super.init(account: account, requestBuilder: Twitter._requestFromInput)
  }
}

// MARK: Native
public class Native : Destination {
  
  typealias Input = Item
  
  private let _account:         ACAccount
  private let _requestBuilder:  Input -> SLRequest
  
  private init(account: ACAccount, requestBuilder: Input -> SLRequest){
    self._account        = account
    self._requestBuilder = requestBuilder
  }
  
  public func share(item: Item) -> RACSignal{
    
    let account        = _account
    let requestBuilder = _requestBuilder
    
    return RACSignal.createSignal{
      (subscriber) in
      
      let disposable  = RACDisposable()
      let request     = requestBuilder(item)
      
      request.account = account
      
      request.performRequestWithHandler{
        (data, response, error) in
        
        if let error = error {
          subscriber.sendError(error)
          return
        }
        
        if let data = data {
          subscriber.sendNext(data)
        }
        
        switch(response.statusCode){
        case 200...299:
          subscriber.sendCompleted()
        default:
          let error = NSError(domain: "com.drop.cher.unknown", code: response.statusCode, userInfo: nil)
          subscriber.sendError(error)
        }
      }
      
      return disposable
    }
  }
}

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
      let topViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
      
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
          let error = NSError(domain: "com.drop.cher.cancelled", code: 1, userInfo: nil)
          subscriber.sendError(error)
        }
      }
      
      // Present
      topViewController?.presentViewController(composeViewController, animated: true, completion: nil)
      
      return RACDisposable(){
        composeViewController.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
      }
    })
  }
}