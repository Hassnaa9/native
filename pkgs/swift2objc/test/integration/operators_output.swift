// Test preamble text

import Foundation

@objc public class Vec2Wrapper: NSObject {
  var wrappedInstance: Vec2

  @objc public var x: Double {
    get {
      wrappedInstance.x
    }
    set {
      wrappedInstance.x = newValue
    }
  }

  @objc public var y: Double {
    get {
      wrappedInstance.y
    }
    set {
      wrappedInstance.y = newValue
    }
  }

  init(_ wrappedInstance: Vec2) {
    self.wrappedInstance = wrappedInstance
  }

  @objc public init(x: Double, y: Double) {
    wrappedInstance = Vec2(x: x, y: y)
  }

  @objc static public func +(lhs lhs: Vec2Wrapper, rhs rhs: Vec2Wrapper) -> Vec2Wrapper {
    let result = Vec2.+(lhs: lhs.wrappedInstance, rhs: rhs.wrappedInstance)
    return Vec2Wrapper(result)
  }

  @objc static public func ==(lhs lhs: Vec2Wrapper, rhs rhs: Vec2Wrapper) -> Bool {
    return Vec2.==(lhs: lhs.wrappedInstance, rhs: rhs.wrappedInstance)
  }

  @objc static public func ***(lhs lhs: Vec2Wrapper, rhs rhs: Vec2Wrapper) -> Double {
    return Vec2.***(lhs: lhs.wrappedInstance, rhs: rhs.wrappedInstance)
  }

}

