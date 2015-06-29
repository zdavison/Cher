//
//  UIViewController+UniversalPresentation.swift
//  Cher
//
//  Created by Zachary Davison on 6/29/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Foundation

extension UIViewController {
  
  func present(){
    let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
    rootViewController?.presentViewControllerFromVisibleViewController(self, animated: true, completion: nil)
  }
  
  func presentViewControllerFromVisibleViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
    NSLog("\(self)")
    if let navigationController = self as? UINavigationController {
      navigationController.topViewController.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: true, completion: nil)
    } else if (presentedViewController != nil) {
      presentedViewController!.presentViewControllerFromVisibleViewController(viewControllerToPresent, animated: true, completion: nil)
    } else {
      presentViewController(viewControllerToPresent, animated: true, completion: nil)
    }
  }
}