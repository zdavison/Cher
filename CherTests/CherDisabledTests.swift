//
//  CherDisabledTests.swift
//  Cher
//
//  Created by Zachary Davison on 6/26/15.
//  Copyright (c) 2015 adaptics. All rights reserved.
//

import Quick
import Nimble
import Cher
import ReactiveCocoa

class CherDisabledSpec : QuickSpec {
  describe("IN PROGRESS"){
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