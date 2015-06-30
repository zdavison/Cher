# Cher
Reactive Swift social sharing, covered by Cher. (Still alpha)

![](http://i1-news.softpedia-static.com/images/news2/Twitter-Account-of-Cher-Hacked-Abused-to-Promote-Shady-Diet-2.png)

You should be familiar with [ReactiveCocoa](http://github.com/reactivecocoa/reactivecocoa) before reading.

# Goals

- One line sharing.
- Unified sharing API eg: `Service.share(item)`
- Extensible.
- Consistent UX where possible.
- Compile time enforcement of compatability / requirements per service.

# Sharing

Cher supports sharing via `Flow`s, which are entirely self contained UI/Logic components that perform editing and sharing themselves.

```swift
    let item = FacebookFlow.Input(text: "i believe in love after love", image: nil, urls: nil)
    Cher.FacebookFlow().share(item).subscribeCompleted{
      NSLog("Share completed.")
    }
```

`Flow`s for Facebook, Twitter, Pinterest, Instagram, and Email are implemented for you.

You can easily implement new `Flow`s by adopting the `Flow` protocol.
