//
//  Day+CoreDataProperties.swift
//  Citrus
//
//  Created by Dilraj Devgun on 7/26/15.
//  Copyright © 2015 Clockwork Development, LLC. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

class Day:NSManagedObject{

    @NSManaged var completed: NSNumber
    @NSManaged var date: NSDate
    @NSManaged var pointsForDay: NSNumber

}
