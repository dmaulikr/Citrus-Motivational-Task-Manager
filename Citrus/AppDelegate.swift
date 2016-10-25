//
//  AppDelegate.swift
//  Citrus
//
//  Created by Dilraj Devgun on 4/5/15.
//  Copyright (c) 2015 Clockwork Development, LLC. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))

        let itemManager = ItemManager.sharedInstance
        itemManager.context = self.managedObjectContext
        let rewardsManager = RewardSystemManager.sharedInstance
        rewardsManager.context = self.managedObjectContext
        let standardUserDefaults = NSUserDefaults.standardUserDefaults()
        let haveUsed = standardUserDefaults.boolForKey("haveused")
        if haveUsed == false
        {
            setUpDefaults()
            standardUserDefaults.setValue(true, forKey: "haveused")
            standardUserDefaults.synchronize()
        }
        UINavigationBar.appearance().shadowImage = UIImage()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.timeChange), name: UIApplicationSignificantTimeChangeNotification, object: nil)
        rewardsManager.update()
        return true
    }
    
    func timeChange()
    {
        let rewardsManager = RewardSystemManager.sharedInstance
        rewardsManager.update()
    }
    
    func setUpDefaults()
    {
        //Create Defaults
        let standardUserDefaults = NSUserDefaults.standardUserDefaults()
        standardUserDefaults.setValue(80, forKey: "catRedBase")
        standardUserDefaults.setValue(176, forKey: "catGreenBase")
        standardUserDefaults.setValue(252, forKey: "catBlueBase")
        
        standardUserDefaults.setValue(191, forKey: "catRedLimit")
        standardUserDefaults.setValue(222, forKey: "catGreenLimit")
        standardUserDefaults.setValue(254, forKey: "catBlueLimit")
        
        standardUserDefaults.setValue(126, forKey: "taskRedBase")
        standardUserDefaults.setValue(209, forKey: "taskGreenBase")
        standardUserDefaults.setValue(95, forKey: "taskBlueBase")
        
        standardUserDefaults.setValue(212, forKey: "taskRedLimit")
        standardUserDefaults.setValue(245, forKey: "taskGreenLimit")
        standardUserDefaults.setValue(176, forKey: "taskBlueLimit")
        standardUserDefaults.synchronize()
        
        let rewardsManager = RewardSystemManager.sharedInstance
        rewardsManager.createNewDay()
        rewardsManager.createRewardSystem()
        let itemMangager = ItemManager.sharedInstance
        itemMangager.addNewCategory("School")
        itemMangager.addNewCategory("Work")
        itemMangager.addNewCategory("App Development")
        itemMangager.addNewCategory("Home")
        itemMangager.addNewTask("Pull down the list", hours: 1, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[0], hasReminder: false, repeatDays:2111111)
        itemMangager.addNewTask("Swipe left to complete", hours: 0, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[0], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Swipe right to delete", hours: 1, minutes: 00, date:NSDate(), category: (itemMangager.getCategories())[0], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Tap a pie piece", hours: 0, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[0], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Tap the small pie chart", hours: 0, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[0], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Pull down the list", hours: 3, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[1], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Swipe left to complete", hours: 1, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[1], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Swipe right to delete", hours: 1, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[1], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Tap a pie piece", hours: 1, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[1], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Tap the small pie chart", hours: 1, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[1], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Pull down the list", hours: 0, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[2], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Swipe left to complete", hours: 0, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[2], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Swipe right to delete", hours: 0, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[2], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Tap a pie piece", hours: 0, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[2], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Tap the small pie chart", hours: 0, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[2], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Pull down the list", hours: 1, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[3], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Swipe left to complete", hours: 1, minutes: 00, date:NSDate(), category: (itemMangager.getCategories())[3], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Swipe right to delete", hours: 3, minutes: 00, date:NSDate(), category: (itemMangager.getCategories())[3], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Tap a pie piece", hours: 0, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[3], hasReminder: false, repeatDays:nil)
        itemMangager.addNewTask("Tap the small pie chart", hours: 0, minutes: 30, date:NSDate(), category: (itemMangager.getCategories())[3], hasReminder: false, repeatDays:nil)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.timeChange), name: UIApplicationSignificantTimeChangeNotification, object: nil)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.timeChange), name: UIApplicationSignificantTimeChangeNotification, object: nil)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.timeChange), name: UIApplicationSignificantTimeChangeNotification, object: nil)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.timeChange), name: UIApplicationSignificantTimeChangeNotification, object: nil)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.timeChange), name: UIApplicationSignificantTimeChangeNotification, object: nil)
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Citrus", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Citrus.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    
}

