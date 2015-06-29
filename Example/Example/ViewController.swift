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
  
  // Facebook
  
  @IBAction func shareTextOnFacebook(){
    Cher.url("i believe in love after love", via: FacebookFlow()).subscribeCompleted{
      NSLog("Share completed.")
    }
  }

  @IBAction func shareURLOnFacebook(){
    Cher.url("http://cherlove.net", via: FacebookFlow()).subscribeCompleted{
      NSLog("Share completed.")
    }
  }
  
  @IBAction func shareImageOnFacebook(){
    let image = UIImage(named: "cher.jpg")!
    Cher.image(image, via: FacebookFlow()).subscribeCompleted{
      NSLog("Share completed.")
    }
  }
  
  // Twitter
  
  @IBAction func shareTextOnTwitter(){
    Cher.url("i believe in love after love", via: FacebookFlow()).subscribeCompleted{
      NSLog("Share completed.")
    }
  }
  
  @IBAction func shareURLOnTwitter(){
    Cher.url("http://cherlove.net", via: FacebookFlow()).subscribeCompleted{
      NSLog("Share completed.")
    }
  }
  
  @IBAction func shareImageOnTwitter(){
    let image = UIImage(named: "cher.jpg")!
    Cher.image(image, via: FacebookFlow()).subscribeCompleted{
      NSLog("Share completed.")
    }
  }
  
  @IBAction func shareImageOnPinterest(){
    let pinterest = PinterestFlow(clientID: "1445992")
    
    let item = PinterestItem(
      text: "i believe in love after love",
      imageURLString: "http://static.idolator.com/uploads/2014/01/31/cher-dressed-to-kill-tour-600x450.jpg",
      sourceURLString: "http://cherlove.net")
    
    Cher.item(item, via: pinterest).subscribeCompleted{
      NSLog("Share completed.")
    }
  }
  
  // Instagram
  @IBAction func shareImageOnInstagram(sender:UIButton){
    let image = UIImage(named: "cher.jpg")!
    Cher.image(image, via: InstagramFlow(sender: sender)).subscribeError({
      NSLog("Error: \($0)")
    },
    completed: {
      NSLog("Share completed.")
    })
  }
  
  // Email
  @IBAction func shareTextViaEmail(sender: UIButton){
    Cher.text("i believe in love after love", via: EmailFlow()).subscribeError({
      NSLog("Error: \($0)")
      },
      completed: {
        NSLog("Share completed.")
    })
  }

}

