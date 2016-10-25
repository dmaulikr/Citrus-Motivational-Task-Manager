//
//  RewardSystemManager.swift
//  Citrus
//
//  Created by Dilraj Devgun on 5/13/15.
//  Copyright (c) 2015 Clockwork Development, LLC. All rights reserved.
//

import Foundation
import CoreData

class RewardSystemManager
{
    class var sharedInstance : RewardSystemManager {
        struct Static {
            static let instance : RewardSystemManager = RewardSystemManager()
        }
        return Static.instance
    }
    var context:NSManagedObjectContext!
    
    func getStreaks() -> [Streak]
    {
        let fetchRequest = NSFetchRequest(entityName: "Streak")
        var fetchedResults:[Streak] = []
        do {
            try fetchedResults = self.context.executeFetchRequest(fetchRequest) as! [Streak]
        }
        catch _
        {
            return fetchedResults
        }
        return fetchedResults
    }
    
    func getLatestStreak() -> Streak?
    {
        var streaks = self.getStreaks()
        if streaks.count == 0
        {
            return nil
        }
        var latest:Streak = streaks[0]
        for i in 1 ..< streaks.count
        {
            if self.isDateBigger(latest.endDate, date2: streaks[i].endDate) == false
            {
                latest = streaks[i]
            }
        }
        return latest
    }
    
    func update()
    {
        /*
        get latest day
        if latest day is same as today then do nothing
        if latest day is not same then calculate days between
        if days between == 1
            calculate streak or no streak for latest day 
        if days between > 1
            calculate streak or no streak for latest day 
            create new bad streak for the day after or including latest day depending on if it was a good streak or not unitl the day before today
        create day for today
        if we are holding greater than seven days then delete them to get seven
        */
        
        let lastDay = self.getLatestDay()
        var components = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: lastDay.date)
        let lastDayDate:NSDate! = NSCalendar.currentCalendar().dateFromComponents(components)
        components = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: NSDate())
        let todayDate:NSDate! = NSCalendar.currentCalendar().dateFromComponents(components)
        
        let fetchRequest = NSFetchRequest(entityName: "RewardsSystem")
        var fetchedResults:[RewardsSystem] = []
        do {
            try fetchedResults = self.context.executeFetchRequest(fetchRequest) as! [RewardsSystem]
        }
        catch _
        {
            return
        }
        let rewards = fetchedResults[0]
        
        if lastDayDate.compare(todayDate) == NSComparisonResult.OrderedSame
        {
            return
        }
        else
        {
            lastDay.pointsForDay = NSNumber(integer: Int(rewards.points))
            do {
                try context.save()
            } catch _ {
                return
            }
            let daysBetweenLastDayAndToday = self.getDaysBetweenDates(lastDayDate, date2: todayDate)
            if daysBetweenLastDayAndToday == 1
            {
                let currentStreak = self.getLatestStreak()
                if let _ = currentStreak
                {
                    if Int(lastDay.completed) >= self.getGoal()
                    {
                        if currentStreak?.isGoodStreak == 1
                        {
                            self.setMultiplier(rewards.multiplier+1)
                            currentStreak?.endDate = lastDayDate
                        }
                        else
                        {
                            //create new good streak and begin and end at last date
                            self.setMultiplier(1)
                            self.createStreak(true, beginDate: lastDayDate, endDate: lastDayDate)
                        }
                    }
                    else
                    {
                        if currentStreak?.isGoodStreak == 1
                        {
                            //create new bad streak and begin and end at last date
                            self.setMultiplier(1)
                            self.createStreak(false, beginDate: lastDayDate, endDate: lastDayDate)
                        }
                        else
                        {
                            self.setMultiplier(1)
                            currentStreak?.endDate = lastDayDate
                            self.updatePoints(false)
                        }
                    }
                }
                else
                {
                    if Int(lastDay.completed) >= self.getGoal()
                    {
                        //create new good streak begin and end at last day date
                        self.setMultiplier(1)
                        self.createStreak(true, beginDate: lastDayDate, endDate: lastDayDate)
                    }
                    else
                    {
                        //create new bad streak begin and end at last day date
                        self.setMultiplier(1)
                        self.createStreak(false, beginDate: lastDayDate, endDate: lastDayDate)
                    }
                }
            }
            else
            {
//                calculate streak or no streak for latest day
//                create new bad streak for the day after or including latest day depending on if it was a good streak or not unitl the day before today
                self.setMultiplier(1)
                let currentStreak = self.getLatestStreak()
                if Int(lastDay.completed) >= self.getGoal()
                {
                    if let _ = currentStreak
                    {
                        if currentStreak?.isGoodStreak == 1
                        {
                            currentStreak?.endDate = lastDayDate
                            
                        }
                        else
                        {
                            let yesterdayDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -1, toDate: todayDate, options: [])
                            self.createStreak(false, beginDate: lastDayDate, endDate: yesterdayDate!)
                        }
                    }
                    else
                    {
                       self.createStreak(true, beginDate: lastDayDate, endDate: lastDayDate)
                        let dayAfter = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: 1, toDate: lastDayDate, options: [])
                        let dayBefore =  NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -1, toDate: todayDate, options: [])
                        self.createStreak(false, beginDate: dayAfter!, endDate: dayBefore!)
                    }
                }
                else
                {
                    if let _ = currentStreak
                    {
                        if currentStreak?.isGoodStreak == 1
                        {
                            currentStreak?.endDate = lastDayDate
                        }
                        else
                        {
                            let yesterdayDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -1, toDate: todayDate, options: [])
                            currentStreak?.endDate = yesterdayDate!
                        }
                    }
                    else
                    {
                        let dayBefore = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -1, toDate: todayDate, options: [])
                        self.createStreak(false, beginDate: lastDayDate, endDate: dayBefore!)
                    }
                }
            }
        }
        self.createNewDay()
        self.updateDays()
        var multiplier:Double = 1
        if self.getLatestStreak()?.isGoodStreak == 1
        {
            multiplier = self.getCurrentStreakLength()+1
        }
        self.setMultiplier(multiplier)
    }
    
    func createRewardSystem()
    {
        let entity:NSEntityDescription =  NSEntityDescription.entityForName("RewardsSystem", inManagedObjectContext:context)!
        let newSystem:RewardsSystem = RewardsSystem(entity: entity, insertIntoManagedObjectContext: self.context)
        newSystem.setValue(5, forKey: "goal")
        newSystem.setValue(1, forKey: "multiplier")
        newSystem.setValue(0, forKey: "points")
        do{
            try context.save()
        } catch _{
        }
    }
    
    func createStreak(isGood:Bool, beginDate:NSDate, endDate:NSDate)
    {
        let entity:NSEntityDescription =  NSEntityDescription.entityForName("Streak", inManagedObjectContext:context)!
        let newStreak:Streak = Streak(entity: entity, insertIntoManagedObjectContext: self.context)
        newStreak.setValue(beginDate, forKey: "beginDate")
        newStreak.setValue(endDate, forKey: "endDate")
        if isGood == true
        {
            newStreak.setValue(1, forKey: "isGoodStreak")
        }
        else
        {
            newStreak.setValue(0, forKey: "isGoodStreak")
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func getCurrentStreakLength() -> Double
    {
        let current = self.getLatestStreak()
        if let cs = current
        {
            return Double(self.getDaysBetweenDates(cs.beginDate, date2: cs.endDate) + 1)
        }
        return 1
    }
    
    func setGoal(goal:Int)
    {
        let fetchRequest = NSFetchRequest(entityName: "RewardsSystem")
        var fetchedResults:[RewardsSystem] = []
        do {
            try fetchedResults = self.context.executeFetchRequest(fetchRequest) as! [RewardsSystem]
        } catch _ {
            return
        }
        fetchedResults[0].goal = Int64(goal)
    }
    
    func getGoal() -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "RewardsSystem")
        var fetchedResults:[RewardsSystem] = []
        do {
            try fetchedResults = self.context.executeFetchRequest(fetchRequest) as! [RewardsSystem]
        } catch _ {
            return -1
        }
        return Int(fetchedResults[0].goal)
    }
    
    func setMultiplier(multiplier:Double)
    {
        let fetchRequest = NSFetchRequest(entityName: "RewardsSystem")
        var fetchedResults:[RewardsSystem] = []
        do {
            try fetchedResults = self.context.executeFetchRequest(fetchRequest) as! [RewardsSystem]
        } catch _ {
            return
        }
        fetchedResults[0].multiplier = multiplier
        
        do {
            try self.context.save()
        } catch _ {
            return
        }
    }
    
    func getMultiplier() -> Double
    {
        let fetchRequest = NSFetchRequest(entityName: "RewardsSystem")
        var fetchedResults:[RewardsSystem] = []
        do {
            try fetchedResults = self.context.executeFetchRequest(fetchRequest) as! [RewardsSystem]
        } catch _ {
            return -1
        }
        return fetchedResults[0].multiplier
    }
    
    func getPoints() -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "RewardsSystem")
        var fetchedResults:[RewardsSystem] = []
        do {
            try fetchedResults = self.context.executeFetchRequest(fetchRequest) as! [RewardsSystem]
        } catch _ {
            return -1
        }
        return Int(fetchedResults[0].points)
    }
    
    func updatePoints(completedTask:Bool)
    {
        let fetchRequest = NSFetchRequest(entityName: "RewardsSystem")
        var fetchedResults:[RewardsSystem] = []
        do {
            try fetchedResults = self.context.executeFetchRequest(fetchRequest) as! [RewardsSystem]
        } catch _ {
            return
        }
        let rewards = fetchedResults[0]
        
        if completedTask == true{
            rewards.points += Int(Double(1)*self.getMultiplier())
            let today = self.getLatestDay()
            today.completed = NSNumber(int: Int(today.completed)+1)
        }
        else{
            if rewards.points != 0 || rewards.points-2 <= 0{
                rewards.points -= 2
            }
            else
            {
                rewards.points = 0
            }
        }
        self.getLatestDay().pointsForDay = NSNumber(integer: Int(rewards.points))
        do {
            try self.context.save()
        } catch _ {
            return
        }
    }
    
    func updateDays()
    {
        var days = self.getDays()
        while days.count >= 7
        {
            var smallest:Day = days[0]
            for x in 1 ..< days.count
            {
                if isDateSmaller(smallest.date, date2: days[x].date) == false
                {
                    smallest = days[x]
                }
            }
            self.context.deleteObject(smallest)
            do {
                try self.context.save()
            } catch _ {
            }
            days = self.getDays()
        }
    }
    
    func createNewDay()
    {
        let components = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: NSDate())
        let todayDate = NSCalendar.currentCalendar().dateFromComponents(components)
        let entity:NSEntityDescription =  NSEntityDescription.entityForName("Day", inManagedObjectContext:context)!
        let newDay:Day = Day(entity: entity, insertIntoManagedObjectContext: self.context)
        newDay.setValue(todayDate, forKey: "date")
        newDay.setValue(0, forKey: "completed")
        do {
            try context.save()
        } catch _ {
            return
        }
    }
    
    func createNewDayForDate(date:NSDate)
    {
        let entity:NSEntityDescription =  NSEntityDescription.entityForName("Day", inManagedObjectContext:context)!
        let newDay:Day = Day(entity: entity, insertIntoManagedObjectContext: self.context)
        newDay.setValue(date, forKey: "date")
        newDay.setValue(0, forKey: "completed")
        do {
            try context.save()
        } catch _ {
            return
        }
    }
    
    func getDays() -> [Day]
    {
        let fetchRequest = NSFetchRequest(entityName: "Day")
        var fetchedResults:[Day] = []
        do {
            try fetchedResults = self.context.executeFetchRequest(fetchRequest) as! [Day]
        } catch _ {
            return fetchedResults
        }
        return fetchedResults
    }
    
    func getLatestDay() -> Day
    {
        var days = self.getDays()
        var largest:Day = days[0]
        for x in 1 ..< days.count
        {
            if isDateBigger(largest.date, date2: days[x].date) == false
            {
                largest = days[x]
            }
        }
        return largest
    }
    
    
    func isDateBigger(date1:NSDate, date2:NSDate) -> Bool
    {
        if date1.compare(date2) == NSComparisonResult.OrderedAscending
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func isDateSmaller(date1:NSDate, date2:NSDate) -> Bool
     {
        if date1.compare(date2) == NSComparisonResult.OrderedAscending
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func orderDatesInAccendingOrder(days:[Day]) -> [Day]
    {
        var temp = days
        if temp.count == 1 || temp.count == 0
        {
            return days
        }
        for _ in 0 ... temp.count-1
        {
            var didSwitch = false
            for x in 0..<temp.count-1
            {
                if self.isDateSmaller(days[x].date, date2: days[x+1].date) == true
                {
                    let element = temp[x]
                    temp[x] = days[x+1]
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

    
    
    func getDaysBetweenDates(date1:NSDate, date2:NSDate) -> Int
    {
        return NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: date1, toDate: date2, options: []).day
        
    }
}
