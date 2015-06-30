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
  
  public struct Input {
    let image:    UIImage
    let caption:  String?
    
    public init(image: UIImage, caption: String){
      self.image    = image
      self.caption  = caption
    }
  }
  
  private static var _currentInstance: InstagramFlow?
  
  private let _subject                        = RACSubject()
  private let _sender                         : UIControl
  private var _documentInteractionController  : UIDocumentInteractionController?
  
  public init(sender: UIControl){
    self._sender = sender
    super.init()
    InstagramFlow._currentInstance = self // This never gets de-allocated because we dont have a good place to do so. Kinda crummy.
  }
  
  public static func available() -> Bool {
    return true
  }
  
  public func share(item: Input) -> RACSignal {
    
    let url = _saveImage(item.image)!
    let documentInteractionController = UIDocumentInteractionController()
    documentInteractionController.delegate = self
    documentInteractionController.URL = url
    documentInteractionController.UTI = "com.instagram.photo"
    if let text = item.caption {
      documentInteractionController.annotation = ["InstagramCaption" : text]
    }
    
    let frame  = self._sender.superview!.convertRect(self._sender.frame, toView: nil)
    documentInteractionController.presentOpenInMenuFromRect(frame, inView: self._sender.superview!, animated: true)
    
    // Need to hold onto this or it'll get de-allocated and we'll crash out
    self._documentInteractionController = documentInteractionController
    
    return _subject
  }
}

extension InstagramFlow : UIDocumentInteractionControllerDelegate {
  public func documentInteractionControllerDidDismissOpenInMenu(controller: UIDocumentInteractionController) {
    _subject.sendCompleted()
  }
}