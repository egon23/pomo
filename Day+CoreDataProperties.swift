//
//  Day+CoreDataProperties.swift
//  
//
//  Created by roli on 30.01.20.
//
//

import Foundation
import CoreData


extension Day {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Day> {
        return NSFetchRequest<Day>(entityName: "Day")
    }

    @NSManaged public var date: Date?
    @NSManaged public var intervals: Int32
    @NSManaged public var sessionsPerDay: NSSet?

}

// MARK: Generated accessors for sessionsPerDay
extension Day {

    @objc(addSessionsPerDayObject:)
    @NSManaged public func addToSessionsPerDay(_ value: Session)

    @objc(removeSessionsPerDayObject:)
    @NSManaged public func removeFromSessionsPerDay(_ value: Session)

    @objc(addSessionsPerDay:)
    @NSManaged public func addToSessionsPerDay(_ values: NSSet)

    @objc(removeSessionsPerDay:)
    @NSManaged public func removeFromSessionsPerDay(_ values: NSSet)

}
