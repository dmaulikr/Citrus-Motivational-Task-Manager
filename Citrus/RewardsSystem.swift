//
//  RewardsSystem.swift
//  Citrus
//
//  Created by Dilraj Devgun on 7/2/15.
//  Copyright (c) 2015 Clockwork Development, LLC. All rights reserved.
//

import Foundation
import CoreData

class RewardsSystem: NSManagedObject {

    @NSManaged var goal: Int64
    @NSManaged var multiplier: Double
    @NSManaged var points: Int64

}
