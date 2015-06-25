//
//  UIWebView+Thumbnail.swift
//  Cher
//
//  Created by Zachary Davison on 6/25/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Foundation
import ReactiveCocoa

// MARK: UIView + Render Image
private extension UIView {
  private func render() -> UIImage {
    let hasAlpha = false
    let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, !hasAlpha, scale)
    let ctx = UIGraphicsGetCurrentContext()
    self.layer.renderInContext(ctx)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
  }
}

// MARK: - UIImage + Resizing
private extension UIImage {
  private func imageWithSize(size: CGSize) -> UIImage{
    
    let maxEdge  = max(self.size.width, self.size.height)
    let cropRect = CGRectMake(0, 0, maxEdge, maxEdge)
    let croppedImage = CGImageCreateWithImageInRect(self.CGImage, cropRect)
    
    UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
    UIImage(CGImage: croppedImage)!.drawInRect(CGRect(origin: CGPointZero, size: size))
    
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage
  }
}

// MARK: - WebThumbnail
internal class WebThumbnail : NSObject {
  
  internal let size: CGSize
  
  private var _image:    UIImage?
  private let _request : NSURLRequest
  
  private lazy var _webView: UIWebView? = {
    [unowned self] in
    let webView = UIWebView(frame: UIScreen.mainScreen().bounds)
    webView.delegate = self
    return webView
  }()
  
  init(url: NSURL, size: CGSize){
    self.size     = size
    self._request = NSURLRequest(URL: url)
    super.init()
  }
  
  internal func render() -> RACSignal{
    if let image = _image {
      return RACSignal.rac_return(image)
    }else{
      _webView?.loadRequest(_request)
      return self.rac_signalForSelector(Selector("webViewDidFinishLoad:"), fromProtocol: UIWebViewDelegate.self)
        .map{
          let t = $0 as! RACTuple
          let webView = t.first as! UIWebView
          let image   = webView.render()
          let scaled = image.imageWithSize(self.size)
          return scaled
        }
        .doNext{
          let x = $0 as! UIImage
          self._webView = nil
        }
    }
  }
}

extension WebThumbnail : UIWebViewDelegate { }