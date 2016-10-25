//
//  ItemManager.swift
//  Citrus
//
//  Created by Dilraj Devgun on 5/3/15.
//  Copyright (c) 2015 Clockwork Development, LLC. All rights reserved.
//

import Foundation
import CoreData

class ItemManager
{
    class var sharedInstance : ItemManager {
        struct Static {
            static let instance : ItemManager = ItemManager()
        }
        return Static.instance
    }
    var context:NSManagedObjectContext!
    
    func addNewTask(name:String, hours:Int, minutes:Int, date:NSDate, category:Category, hasReminder:Bool, repeatDays:Int?)
    {
        let entity:NSEntityDescription =  NSEntityDescription.entityForName("Task", inManagedObjectContext:context)!
        let newTask:Task = Task(entity: entity, insertIntoManagedObjectContext: self.context)
        
        let components = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: date)
        
        newTask.setValue(name, forKey: "name")
        newTask.setValue(hours, forKey: "hours")
        newTask.setValue(minutes, forKey: "minutes")
        newTask.setValue(category, forKey: "category")
        newTask.setValue(components.day, forKey: "day")
        newTask.setValue(components.month, forKey: "month")
        newTask.setValue(components.year, forKey: "year")
        newTask.setValue(hasReminder, forKey: "hasReminder")
        if let _ = repeatDays
        {
            newTask.setValue(repeatDays, forKey: "repeatCode")
            newTask.setValue(true, forKey: "isRepeatable")
        }
        else
        {
            newTask.setValue(1111111, forKey: "repeatCode")
            newTask.setValue(false, forKey: "isRepeatable")
        }
        //update Category Time
        var items = category.tasks.allObjects
        let catForTask = category
        catForTask.hours = 0
        catForTask.minutes = 0
        for x in 0 ..< items.count
        {
            catForTask.hours += items[x].hours
            catForTask.minutes += items[x].minutes
        }
        let leftOverHours = catForTask.minutes/60
        let leftOverMinutes = catForTask.minutes%60
        catForTask.hours += Int(leftOverHours)
        catForTask.minutes = leftOverMinutes
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func setRepeatCodeForTask(task:Task, code:Int)
    {
        if code != 1111111
        {
            task.repeatCode = Int64(code)
            task.isRepeatable = true
        }
        else
        {
            task.repeatCode = Int64(code)
            task.isRepeatable = false
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func updateTask(task:Task, name:String, hours:Int, minutes:Int)
    {
        task.name = name
        task.hours = Int32(hours)
        task.minutes = Int64(minutes)
        //update category time
        var items = task.category!.tasks.allObjects
        let catForTask = task.category
        catForTask!.hours = 0
        catForTask!.minutes = 0
        for x in 0 ..< items.count
        {
            catForTask!.hours += items[x].hours
            catForTask!.minutes += items[x].minutes
        }
        let leftOverHours = catForTask!.minutes/60
        let leftOverMinutes = catForTask!.minutes%60
        catForTask!.hours += Int(leftOverHours)
        catForTask!.minutes = leftOverMinutes
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func updateDateForTask(task:Task, date:NSDate)
    {
        let components = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: date)
        task.day = Int64(components.day)
        task.month = Int64(components.month)
        task.year = Int64(components.year)
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func completeTask(task:Task)
    {
        let rewards = RewardSystemManager.sharedInstance
        rewards.updatePoints(true)
        let category = task.category
        self.context.deleteObject(task)
        self.recalculateTimeForCategory(category!)
        do {
            try self.context.save()
        } catch _ {
        }
    }
    
    func completeTaskForDate(task:Task, date:NSDate)
    {
        let rewards = RewardSystemManager.sharedInstance
        rewards.updatePoints(true)
        let category = task.category
        if task.isRepeatable == true
        {
            //get current day number
            //find the new number from the code
            var comp = NSCalendar.currentCalendar().component(NSCalendarUnit.Weekday, fromDate: date)
            comp -= 1
            var splitCode:[Int] = []
            var code = Int(task.repeatCode)
            while code > 0
            {
                splitCode.append(code%10)
                code = code/10
            }
            splitCode = splitCode.reverse()

            var index = comp+1
            var iterations = 1
            for _ in 0 ..< 7
            {
                if splitCode[index] == 2
                {
                    break;
                }
                iterations += 1
                if index == 6
                {
                    index = 0
                }
                else
                {
                    index += 1
                }
            }
            let newDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: iterations, toDate: date, options: [])!
            let components = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: newDate)
            task.day = Int64(components.day)
            task.month = Int64(components.month)
            task.year = Int64(components.year)
        }
        else
        {
            self.context.deleteObject(task)
        }
        self.recalculateTimeForCategory(category!)
        do {
            try self.context.save()
        } catch _ {
        }
    }
    
    func deleteTask(task:Task)
    {
        let category = task.category
        self.context.deleteObject(task)
        self.recalculateTimeForCategory(category!)
        do {
            try self.context.save()
        } catch _ {
        }
    }
    
    func recalculateTimeForCategory(category:Category)
    {
        //update Category Time
        var items = category.tasks.allObjects
        let catForTask = category
        catForTask.hours = 0
        catForTask.minutes = 0
        for x in 0 ..< items.count
        {
            catForTask.hours += items[x].hours
            catForTask.minutes += items[x].minutes
        }
        let leftOverHours = catForTask.minutes/60
        let leftOverMinutes = catForTask.minutes%60
        catForTask.hours += Int(leftOverHours)
        catForTask.minutes = leftOverMinutes
    }
    
    func getTasksInCategoryForDate(category:Category, date:NSDate) -> [Task]
    {
        let allTasks = self.getTasksInCategory(category)
        var tasksForDate:[Task] = []
        for task in allTasks
        {
            let components = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: date)
            
            if Int(task.day) == components.day && Int(task.month) == components.month && Int(task.year) == components.year
            {
                tasksForDate.append(task)
            }
            else if task.isRepeatable == true
            {
                var splitCode:[Int] = []
                var code = Int(task.repeatCode)
                while code > 0
                {
                    splitCode.append(code%10)
                    code = code/10
                }
                splitCode = splitCode.reverse()
                let comp = NSCalendar.currentCalendar().component(NSCalendarUnit.Weekday, fromDate: date)
                if splitCode[comp-1] == 2
                {
                    tasksForDate.append(task)
                }
            }
            
        }
        return tasksForDate
    }
    
    func getTasksInCategory(categoryName:Category) -> [Task]
    {
        var tasks:[Task] = []
        let temp = categoryName.tasks
        tasks = temp.allObjects as! [Task]
        tasks = self.orderTasks(tasks)
        return tasks
    }
    
    func orderCategories(categories:[Category]) -> [Category]
    {
        var temp = categories
        if temp.count == 1 || temp.count == 0
        {
            return categories
        }
        for _ in 0 ... temp.count - 1
        {
            var didSwitch = false
            for x in 0 ..< temp.count - 1
            {
                let element = temp[x]
                let nextElement = temp[x+1]
                let elementTime = (CGFloat(element.hours)*100)+CGFloat(element.minutes)
                let nextElementTime = (CGFloat(nextElement.hours)*100)+CGFloat(nextElement.minutes)
                if elementTime < nextElementTime
                {
                    temp[x] = nextElement
                    temp[x+1] = element
                    didSwitch = true
                }
            }
            if didSwitch == false
            {
                break;
            }
        }
        return temp
    }
    
    func orderTasks(tasks:[Task]) -> [Task]
    {
        //BUBBLE SORT
        //go through each element in the list n-1 times and have a switch variable so if no elements are changed there is no need to continue looping
        //Theoretically we want to compare the element to the element to the right and if the first element is larger switch them. Continue until sorted. 
        var temp = tasks
        if temp.count == 1 || temp.count == 0
        {
            return tasks
        }
        for _ in 0 ... temp.count-1
        {
            var didSwitch = false
            for x in 0..<temp.count-1
            {
                let element = temp[x]
                let nextElement = temp[x+1]
                let elementTime = (CGFloat(element.hours)*100)+CGFloat(element.minutes)
                let nextElementTime = (CGFloat(nextElement.hours)*100)+CGFloat(nextElement.minutes)
                if elementTime < nextElementTime
                {
                    temp[x] = nextElement
                    temp[x+1] = element
                    didSwitch = true
                }
            }
            if didSwitch == false
            {
                break;
            }
        }
        
        return temp
    }
    
    func addNewCategory(name:String)
    {
        let entity:NSEntityDescription =  NSEntityDescription.entityForName("Category", inManagedObjectContext:context)!
        let newCategory:Category = Category(entity: entity, insertIntoManagedObjectContext: self.context)
        newCategory.setValue(name, forKey: "name")
        newCategory.setValue(0, forKey: "hours")
        newCategory.setValue(0, forKey: "minutes")
        do{
            try self.context.save()
        } catch _ {
        }
    }
    
    func updateCategory(category:Category, name:String)
    {
        category.name = name
    }
    
    func removeCategory(category:Category)
    {
        self.context.deleteObject(category)
        do {
            try self.context.save()
        } catch _ {
        }
    }
    
    func getCategories() -> [Category]
    {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        var fetchedResults:[Category] = []
        do {
            try fetchedResults = self.context.executeFetchRequest(fetchRequest) as! [Category]
        }
        catch _
        {
            return fetchedResults
        }
        fetchedResults = self.orderCategories(fetchedResults)
        for i in 0 ..< fetchedResults.count
        {
            self.recalculateTimeForCategory(fetchedResults[i])
        }
        return fetchedResults
    }
    
    func getCategoriesForDate(date:NSDate) -> [Category]
    {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        var fetchedResults:[Category] = []
        do {
            try fetchedResults = self.context.executeFetchRequest(fetchRequest) as! [Category]
        }
        catch _
        {
            return fetchedResults
        }
        fetchedResults = self.orderCategories(fetchedResults)
        for i in 0 ..< fetchedResults.count
        {
            self.recalculatetimeForCategoryWithDate(fetchedResults[i], date: date)
        }
        return fetchedResults
    }
    
    func recalculatetimeForCategoryWithDate(category:Category, date:NSDate)
    {
        //update Category Time
        var items = category.tasks.allObjects
        let catForTask = category
        catForTask.hours = 0
        catForTask.minutes = 0
        for x in 0 ..< items.count
        {
            let task = items[x] as! Task
            let components = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: date)
            if Int(task.day) == components.day && Int(task.month) == components.month && Int(task.year) == components.year
            {
                catForTask.hours += items[x].hours
                catForTask.minutes += items[x].minutes
            }
            else if task.isRepeatable == true
            {
                var splitCode:[Int] = []
                var code = Int(task.repeatCode)
                while code > 0
                {
                    splitCode.append(code%10)
                    code = code/10
                }
                splitCode = splitCode.reverse()
                let comp = NSCalendar.currentCalendar().component(NSCalendarUnit.Weekday, fromDate: date)
                if splitCode[comp-1] == 2
                {
                    catForTask.hours += items[x].hours
                    catForTask.minutes += items[x].minutes
                }
            }
        }
        let leftOverHours = catForTask.minutes/60
        let leftOverMinutes = catForTask.minutes%60
        catForTask.hours += Int(leftOverHours)
        catForTask.minutes = leftOverMinutes
    }
}
