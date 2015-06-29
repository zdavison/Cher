//
//  ImageComposeViewController.swift
//  Cher
//
//  Created by Zachary Davison on 6/24/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Foundation
import Social
import ReactiveCocoa
import MobileCoreServices

// MARK: UIView + Find
private extension UIView{
  func first(className: String) -> UIView? {
    if NSStringFromClass(self.dynamicType) == className { return self }
    for subview in self.subviews as! [UIView]{
      if let found = subview.first(className) { return found }
    }
    return nil
  }
  
  func find(className: String, var reduce: [UIView] = []) -> [UIView] {
    if NSStringFromClass(self.dynamicType) == className { reduce.append(self) }
    for subview in self.subviews as! [UIView]{
      reduce += subview.find(className)
    }
    return reduce
  }
}

// MARK: - ItemProvidable
public protocol Previewable {
  func loadPreview(size: CGSize) -> RACSignal
}

extension NSItemProvider : Previewable {
  public func loadPreview(size: CGSize) -> RACSignal {
    return RACSignal.createSignal{
      [weak self]
      (subscriber) in
      let disposable = RACDisposable()
      
      let scale       = UIScreen.mainScreen().scale
      let scaledSize  = CGSizeMake(size.width * scale, size.height * scale)
      let options     = [NSItemProviderPreferredImageSizeKey: NSValue(CGSize:scaledSize)]
      
      self?.loadPreviewImageWithOptions(options){
        (result: NSSecureCoding?, error: NSError?) in
        
        if let error = error {
          subscriber.sendError(error)
          return
        }
        if let image = result as? UIImage {
          subscriber.sendNext(image)
          subscriber.sendCompleted()
        }
      }
      
      return disposable
    }
  }
}

extension NSURL : Previewable {
  public func loadPreview(size: CGSize) -> RACSignal {
    return WebThumbnail(url: self, size: size).render()
  }
}

extension UIImage : Previewable {
  public func loadPreview(size: CGSize) -> RACSignal {
    return RACSignal.rac_return(self) //TODO: This should respect the size!
  }
}

// MARK: - PreviewComposeServiceViewController
public class PreviewComposeServiceViewController : SLComposeServiceViewController {
  
  public var attachment:    Previewable?
  public var imageView:     UIImageView?
  public var cancelHandler: (Void -> Void)?
  public var postHandler:   (Void -> Void)?
  public var text: String?{
    get {
      if let view = textView { return textView.text        }
      else                   { return _temporaryTextStore  }
    }
    set {
      if let view = textView { textView.text       = newValue }
      else                   { _temporaryTextStore = newValue }
    }
  }
  
  private var _temporaryTextStore:    String? // Used if text is set before view is loaded
  private var _originalBarButtonItem: UIBarButtonItem?
  private let kImageViewSize = CGSizeMake(70, 70)
  
  public override func viewDidLoad() {
    textView.text = _temporaryTextStore
  }
  
  public override func didSelectCancel() {
    cancelHandler?()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  public func _didSelectPost() {
    postHandler?()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if let contentView = view.first("SLSheetContentView"){
    
      textView.textContainerInset.right = 68
      
      let imageView = UIImageView(frame: CGRectMake(
        contentView.bounds.size.width - kImageViewSize.width - 14,
        14,
        kImageViewSize.width,
        kImageViewSize.height))
      
      contentView.addSubview(imageView)
      
      imageView.layer.borderColor = UIColor.lightGrayColor().CGColor
      imageView.layer.borderWidth = 1
      
      imageView.backgroundColor = UIColor.lightTextColor()
      
      self.imageView = imageView
      
      attachment?.loadPreview(kImageViewSize).subscribeNext{
        let image = $0 as! UIImage
        imageView.image = image
      }
    }
  }
}