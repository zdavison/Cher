# Cher
Reactive Swift social sharing, covered by Cher. (Still alpha)

![](http://i1-news.softpedia-static.com/images/news2/Twitter-Account-of-Cher-Hacked-Abused-to-Promote-Shady-Diet-2.png)

You should be familiar with [ReactiveCocoa](http://github.com/reactivecocoa/reactivecocoa) before reading.

# Features

Cher supports sharing via `Flow`s, which are entirely self contained UI/Logic components that perform editing and sharing themselves.

```swift
Cher.url("http://cherlove.net/links.htm").via(FacebookFlow()).subscribeError({
    NSLog("Share failed: \($0)")
  }, 
  completed: {
    NSLog("Share completed!")
  }
)
```

Cher also supports sharing via `Destination`, which will share without UI. This assumes you've prepared everything necessary.

```swift
let account  = Facebook.account // An ACAccount object representing the system Facebook account
let facebook = Facebook(account: myAccount) 
Cher.url("http://cherlove.net/links.htm").to(facebook).subscribeError({
    NSLog("Share failed: \($0)")
  }, 
  completed: {
    NSLog("Share completed!")
  }
)
```

Cher also supports sharing via `Destination` using an `Interface`, which is an object responsible for transforming an `Item` to an `Input`. Provided the `Input` type on your `Destination` is the same as the `Interface`s `Output` type, you can use any interface you like with any destination you like.

You can implement new `Destination`s or `Interface`s purely by adopting their protocol.

These are usually UI, but don't necessarily have to be.
