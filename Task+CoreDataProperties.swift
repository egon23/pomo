//
//  Task+CoreDataProperties.swift
//  
//
//  Created by roli on 30.01.20.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var estimatedHours: Double
    @NSManaged public var intervals: Int32
    @NSManaged public var name: String?
    @NSManaged public var workedHours: Double
    @NSManaged public var deadline: Date?
    @NSManaged public var tasksOfSession: NSSet?

}

// MARK: Generated accessors for tasksOfSession
extension Task {

    @objc(addTasksOfSessionObject:)
    @NSManaged public func addToTasksOfSession(_ value: Session)

    @objc(removeTasksOfSessionObject:)
    @NSManaged public func removeFromTasksOfSession(_ value: Session)

    @objc(addTasksOfSession:)
    @NSManaged public func addToTasksOfSession(_ values: NSSet)

    @objc(removeTasksOfSession:)
    @NSManaged public func removeFromTasksOfSession(_ values: NSSet)

}
