//
//  Cher+Instagram.swift
//  Cher
//
//  Created by Zachary Davison on 6/25/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Foundation
import ReactiveCocoa

private func _saveImage(image: UIImage) -> NSURL? {
  let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as? String
  let filePath      = documentsPath?.stringByAppendingPathComponent("/temp.ig")
  
  if let path = filePath{
    let data = UIImageJPEGRepresentation(image, 9.5)
    data.writeToFile(path, atomically: true)
    return NSURL(fileURLWithPath: path)
  }
  
  return nil
}

public class InstagramFlow : NSObject, Flow {
  
  typealias Input = Item
  
  let sender: UIControl
  
  public init(sender: UIControl){
    self.sender = sender
  }
  
  public func share(item: Item) -> RACSignal {
    
    if item.image == nil{
      let error = NSError(domain: kCherErrorDomain, code: ErrorCode.BadData.rawValue, userInfo: [NSLocalizedDescriptionKey: "Instagram sharing requires an image in \(item)."])
      return RACSignal.error(error)
    }
    
    return RACSignal.createSignal{
      (subscriber) in
      
      let disposable = RACDisposable()
      
      let url = _saveImage(item.image!)!
      let documentInteractionController = UIDocumentInteractionController()
      documentInteractionController.URL = url
      documentInteractionController.UTI = "com.instagram.photo"
      if let text = item.text {
        documentInteractionController.annotation = ["InstagramCaption" : text]
      }
      
      let frame  = self.sender.superview!.convertRect(self.sender.bounds, toView: nil)
      documentInteractionController.presentOpenInMenuFromRect(frame, inView: self.sender.superview!, animated: true)
      
      // TODO: We should be using delegate callbacks to do this (so we can detect cancellation), but we're deallocated before the delegate calls back.
      subscriber.sendCompleted()
      
      return disposable
    }
  }
}