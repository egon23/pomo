//
//  Session+CoreDataProperties.swift
//  
//
//  Created by roli on 30.01.20.
//
//

import Foundation
import CoreData


extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var breaks: Int32
    @NSManaged public var intervals: Int32
    @NSManaged public var time: Double
    @NSManaged public var sessionsPerDay: NSSet?
    @NSManaged public var tasksOfSession: NSSet?

}

// MARK: Generated accessors for sessionsPerDay
extension Session {

    @objc(addSessionsPerDayObject:)
    @NSManaged public func addToSessionsPerDay(_ value: Day)

    @objc(removeSessionsPerDayObject:)
    @NSManaged public func removeFromSessionsPerDay(_ value: Day)

    @objc(addSessionsPerDay:)
    @NSManaged public func addToSessionsPerDay(_ values: NSSet)

    @objc(removeSessionsPerDay:)
    @NSManaged public func removeFromSessionsPerDay(_ values: NSSet)

}

// MARK: Generated accessors for tasksOfSession
extension Session {

    @objc(addTasksOfSessionObject:)
    @NSManaged public func addToTasksOfSession(_ value: Task)

    @objc(removeTasksOfSessionObject:)
    @NSManaged public func removeFromTasksOfSession(_ value: Task)

    @objc(addTasksOfSession:)
    @NSManaged public func addToTasksOfSession(_ values: NSSet)

    @objc(removeTasksOfSession:)
    @NSManaged public func removeFromTasksOfSession(_ values: NSSet)

}
