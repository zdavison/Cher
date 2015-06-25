//
//  ViewController.swift
//  Example
//
//  Created by Zachary Davison on 6/24/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import UIKit
import Cher
import Social

class ViewController: UIViewController {

  @IBAction func shareURLOnFacebook(){
    Cher.url("http://cherlove.net").via(FacebookFlow()).subscribeCompleted{
      NSLog("Share completed.")
    }
  }
  
  @IBAction func shareURLOnTwitter(){
    Cher.url("http://cherlove.net").via(TwitterFlow()).subscribeCompleted{
      NSLog("Share completed.")
    }
  }
  
  @IBAction func shareTextOnFacebook(){
    Cher.text("i believe in love after love").via(FacebookFlow()).subscribeCompleted{
      NSLog("Share completed.")
    }
  }
  
  @IBAction func shareTextOnTwitter(){
    Cher.text("i believe in love after love").via(TwitterFlow()).subscribeCompleted{
      NSLog("Share completed.")
    }
  }
  
  @IBAction func shareImageOnFacebook(){
    let previewComposeViewController = PreviewComposeServiceViewController()
    previewComposeViewController.attachment = NSURL(string: "http://placekitten.com")
    self.presentViewController(previewComposeViewController, animated: true, completion: nil)
  }
  
  @IBAction func shareImageOnTwitter(){

  }
}

