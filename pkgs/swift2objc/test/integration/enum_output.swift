// Test preamble text

import Foundation

// Status enum wrapper
@objc public class StatusWrapper: NSObject {
    public var wrappedInstance: Status

    @objc public init(_ status: Status) {
        self.wrappedInstance = status
    }

    @objc public var rawValue: String {
        return wrappedInstance.rawValue
    }

    public static func ==(lhs: StatusWrapper, rhs: StatusWrapper) -> Bool {
        return lhs.wrappedInstance == rhs.wrappedInstance
    }

    public static func !=(lhs: StatusWrapper, rhs: StatusWrapper) -> Bool {
        return lhs.wrappedInstance != rhs.wrappedInstance
    }
}

@objc public class BeverageWrapper: NSObject {
    public var wrappedInstance: Beverage

    @objc public init(_ beverage: Beverage) {
        self.wrappedInstance = beverage
    }

    public static func ==(lhs: BeverageWrapper, rhs: BeverageWrapper) -> Bool {
        return lhs.wrappedInstance == rhs.wrappedInstance
    }

    public static func !=(lhs: BeverageWrapper, rhs: BeverageWrapper) -> Bool {
        return lhs.wrappedInstance != rhs.wrappedInstance
    }
}

@objc public class DayOfWeekWrapper: NSObject {
    public var wrappedInstance: DayOfWeek

    @objc public init(_ day: DayOfWeek) {
        self.wrappedInstance = day
    }

    @objc public var rawValue: Int {
        return wrappedInstance.rawValue
    }

    public static func ==(lhs: DayOfWeekWrapper, rhs: DayOfWeekWrapper) -> Bool {
        return lhs.wrappedInstance == rhs.wrappedInstance
    }

    public static func !=(lhs: DayOfWeekWrapper, rhs: DayOfWeekWrapper) -> Bool {
        return lhs.wrappedInstance != rhs.wrappedInstance
    }
}
