// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public func funcStringWrapper() -> String? {
    return funcString()
  }

  @objc static public func funcNSErrorWrapper() -> NSErrorWrapper? {
    let result = funcNSError()
    return result == nil ? nil : NSErrorWrapper(result!)
  }

  @objc static public func funcIndexSetWrapper() -> IndexSet? {
    return funcIndexSet()
  }

  @objc static public func funcCharacterSetWrapper() -> CharacterSet? {
    return funcCharacterSet()
  }

  @objc static public func funcNotificationWrapper() -> Notification? {
    return funcNotification()
  }

  @objc static public func funcAffineTransformWrapper() -> AffineTransform? {
    return funcAffineTransform()
  }

}

// This wrapper is a stub. To generate the full wrapper, add NSError
// to your config's include function.
@objc public class NSErrorWrapper: NSObject {
  var wrappedInstance: NSError

  init(_ wrappedInstance: NSError) {
    self.wrappedInstance = wrappedInstance
  }

}

