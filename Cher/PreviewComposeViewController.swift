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
  func find(className: String) -> UIView? {
    if NSStringFromClass(self.dynamicType) == className { return self }
    for subview in self.subviews as! [UIView]{
      if let found = subview.find(className) { return found }
    }
    return nil
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

// MARK: - PreviewComposeServiceViewController
public class PreviewComposeServiceViewController : SLComposeServiceViewController {
  
  public var attachment: Previewable?
  public var imageView:  UIImageView?
  
  private let kImageViewSize = CGSizeMake(70, 70)
  
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if let contentView = view.find("SLSheetContentView"){
    
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