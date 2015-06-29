//
//  Cher+Email.swift
//  Cher
//
//  Created by Zachary Davison on 6/29/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Foundation
import ReactiveCocoa
import MessageUI

public class EmailFlow : NSObject, Flow {
  
  private static var _currentInstance: EmailFlow?
  
  private let _subject = RACSubject()
  
  public override init(){
    super.init()
    EmailFlow._currentInstance = self
  }
  
  deinit{
    NSLog("deinit")
  }
  
  public static func available() -> Bool {
    return MFMailComposeViewController.canSendMail()
  }
  
  typealias Input = Item
  public func share(item: Item) -> RACSignal {
    
    let composeViewController = MFMailComposeViewController()
    composeViewController.mailComposeDelegate = self
    composeViewController.setSubject("Check out this cool recipe from Drop.")
    composeViewController.setMessageBody(item.text, isHTML: false)
    composeViewController.present()
    
    return _subject
  }
}

extension EmailFlow : MFMailComposeViewControllerDelegate {
  
  public func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
    controller.dismissViewControllerAnimated(true, completion: nil)
    EmailFlow._currentInstance = nil
    
    switch result.value{
    case MFMailComposeResultSent.value:
      _subject.sendCompleted()
    case MFMailComposeResultSaved.value:
      _subject.sendCompleted()
    case MFMailComposeResultCancelled.value:
      let error = NSError(domain: kCherErrorDomain, code: ErrorCode.User.rawValue, userInfo: [NSLocalizedDescriptionKey:"User cancelled share."])
      _subject.sendError(error)
    case MFMailComposeErrorCodeSendFailed.value:
      _subject.sendError(error)
    default:
      let error = NSError(domain: kCherErrorDomain, code: ErrorCode.Unknown.rawValue, userInfo: [NSLocalizedDescriptionKey: "Unknown error occured."])
      _subject.sendError(error)
    }
  }
}

extension EmailFlow : UINavigationControllerDelegate {}