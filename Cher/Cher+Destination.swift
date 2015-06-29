//
//  Cher+Destinations.swift
//  Cher
//
//  Created by Zachary Davison on 6/26/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Foundation
import ReactiveCocoa

//MARK:  - Native + Destination -

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

// MARK: - Destination -

//MARK: Item
public extension Item {
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

// MARK: Cher
public extension Cher {
  
  // Sharing with Destinations
  public class func url<D: Destination where D.Input == Item>(urlString: String, to: D) -> RACSignal {
    let item = Item(text: urlString)
    return to.share(item)
  }
  public class func text<D: Destination where D.Input == Item>(text: String, to: D) -> RACSignal {
    let item = Item(text: text)
    return to.share(item)
  }
  public class func image<D: Destination where D.Input == Item>(image: UIImage, to: D) -> RACSignal {
    let item = Item(image: image)
    return to.share(item)
  }
  public class func item<I: Item, D: Destination where D.Input == I>(item: I, to: D) -> RACSignal {
    return to.share(item)
  }
  
  //TODO: Sharing with Destinations + Interfaces
  
}