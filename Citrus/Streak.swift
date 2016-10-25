//
//  Streak.swift
//  Citrus
//
//  Created by Dilraj Devgun on 7/2/15.
//  Copyright (c) 2015 Clockwork Development, LLC. All rights reserved.
//

import Foundation
import CoreData

class Streak: NSManagedObject {

    @NSManaged var beginDate: NSDate
    @NSManaged var endDate: NSDate
    @NSManaged var isGoodStreak: NSNumber

}
