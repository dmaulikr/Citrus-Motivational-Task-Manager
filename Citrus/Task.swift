//
//  Task+CoreDataProperties.swift
//  Citrus
//
//  Created by Dilraj Devgun on 7/29/15.
//  Copyright © 2015 Clockwork Development, LLC. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

class Task:NSManagedObject {

    @NSManaged var day: Int64
    @NSManaged var hasReminder: Bool
    @NSManaged var hours: Int32
    @NSManaged var isRepeatable: Bool
    @NSManaged var minutes: Int64
    @NSManaged var month: Int64
    @NSManaged var name: String?
    @NSManaged var year: Int64
    @NSManaged var repeatCode: Int64
    @NSManaged var category: Category?

}
