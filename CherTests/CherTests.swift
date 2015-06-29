//
//  CherTests.swift
//  CherTests
//
//  Created by Zachary Davison on 6/23/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Cher
import Quick
import Nimble
import ReactiveCocoa

class ItemSpec : QuickSpec {
  override func spec(){
    describe("Item"){
      it("should be able to parse URLs from text on initialization"){
        let item = Item(text: "wow, http://cherlove.net is a great website")
        expect(item.URLs.first).to(equal(NSURL(string: "http://cherlove.net")))
      }
      it("should return an empty array if no URLs are present"){
        let item = Item(text: "wow, cher is great")
        expect(item.URLs.count).to(equal(0))
      }
    }
  }
}

class CherSpec : QuickSpec {
  override func spec() {
    describe("Cher top level API"){
      context("delegating sharing to a flow"){
        
        class SucceedingFlow : Flow {
          private func share(item: Item) -> RACSignal {
            return RACSignal.empty()
          }
        }
        
        class CancellingFlow : Flow {
          private func share(item: Item) -> RACSignal {
            let error = NSError(domain: "com.drop.cher.test", code: 0, userInfo: nil)
            return RACSignal.error(error)
          }
        }
        
        it("should return a signal that completes on successful share"){
          var completed: Bool?
          Cher.url("http://cherlove.net", via: SucceedingFlow()).subscribeCompleted{
            completed = true
          }
          expect(completed).toEventually(equal(true))
        }
  
        it("should return a signal that errors on cancelled / failed share"){
          var error: NSError?
          Cher.url("http://cherlove.net", via: CancellingFlow()).subscribeError{
            error = $0
          }
          expect(error).toEventuallyNot(beNil())
        }
      }
    }
  }
}