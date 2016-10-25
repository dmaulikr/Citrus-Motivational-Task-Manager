//
//  Category.swift
//  Citrus
//
//  Created by Dilraj Devgun on 5/3/15.
//  Copyright (c) 2015 Clockwork Development, LLC. All rights reserved.
//

import Foundation
import CoreData

class Category: NSManagedObject {

    @NSManaged var hours: Int64
    @NSManaged var minutes: Int32
    @NSManaged var name: String
    @NSManaged var tasks: NSSet

}
