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
          Cher.url("http://cherlove.net").via(SucceedingFlow()).subscribeCompleted{
            completed = true
          }
          expect(completed).toEventually(equal(true))
        }
  
        it("should return a signal that errors on cancelled / failed share"){
          var error: NSError?
          Cher.url("http://cherlove.net").via(CancellingFlow()).subscribeError{
            error = $0
          }
          expect(error).toEventuallyNot(beNil())
        }
      }
      
      context("delegating sharing to a destination via an interface"){
        
        class ItemDestination: Destination {
          typealias Input = Item
          private func share(input: Input) -> RACSignal {
            return RACSignal.empty()
          }
        }
        
        class StringDestination: Destination {
          typealias Input = String
          private func share(input: Input) -> RACSignal {
            return RACSignal.empty()
          }
        }
        
        class StringReturningInterface: Interface {
          typealias Output = String
          private func present(item: Item) -> RACSignal {
            return RACSignal.rac_return("i believe in love after love")
          }
        }
        
        it("a destination should perform its share"){
          var completed = false
          Cher.url("http://cherlove.net").to(ItemDestination()).subscribeCompleted{
            Void -> Void in
            completed = true
          }
          expect(completed).toEventually(beTrue())
        }
        
        it("an interface can mutate an Item into an Output type"){
          var output: String?
          StringReturningInterface().present(Item(text: "")).subscribeNext{
            output = $0 as? String
          }
          expect(output).toEventually(equal("i believe in love after love"))
        }
        
        it("an interface/destination pair can perform a share"){
          var completed = false
          Cher.url("http://cherlove.net").to(StringDestination(), using: StringReturningInterface())
            .subscribeCompleted{
            completed = true
          }
          expect(completed).toEventually(beTrue())
        }
      }
    }
  }
}