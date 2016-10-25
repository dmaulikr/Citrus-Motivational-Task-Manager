//
//  CustomCell.swift
//  Project Tide
//
//  Created by Dilraj Devgun on 1/17/15.
//  Copyright (c) 2015 Clockwork Development, LLC. All rights reserved.
//

import UIKit
import CoreData

protocol CustomCellDelegate
{
    func presentGridMenuView(type:GridPresentationType)
    func dismissedAlertView()
}

enum GridPresentationType
{
    case reschedule
    case reminder
    case repeating
    
}

class CustomCell: MGSwipeTableCell, CNPGridMenuDelegate {

    
    
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var colourIndicator: UIView!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var cellTime: UILabel!
    @IBOutlet weak var cellName: MarqueeLabel!
    var item:NSManagedObject!
    var initialSkip = true
    var num = -1
    let tintColour = UIColor(red: 245/255, green: 112/255, blue: 71/255, alpha: 1)
    var longPressRecognizer:UILongPressGestureRecognizer!
    var cellTimeFrame:CGRect!
    var cellNameFrame:CGRect!
    var cellDelegate:CustomCellDelegate!
    
    func setValuesForCell(name:String, time:String)
    {
        self.cellName.attributedText = self.kern(3, text: name, fontSize: 18)
        self.cellTime.attributedText = self.kern(3, text: time, fontSize: 13)
        self.cellName.sizeToFit()
        self.cellTime.sizeToFit()
        if self.cellName.frame.width >= self.frame.width
        {
            self.cellName.frame = CGRectMake((self.frame.width/2)-40, self.cellName.frame.minY, self.frame.width-80, self.cellName.frame.height)
        }
    }
    
    func setUpButton()
    {
        if (item as! Task).hasReminder == true{
            self.reminderButton.selected = true
        }
        else
        {
            self.reminderButton.selected = false
        }
        
        if (item as! Task).isRepeatable == true
        {
            self.repeatButton.selected = true
        }
        else
        {
            self.repeatButton.selected = false
        }
    }
    
    func setColourForIndicator(color:UIColor)
    {
        self.colourIndicator.layer.cornerRadius = self.colourIndicator.frame.width/2
        self.colourIndicator.backgroundColor = color
    }
    
    func kern(kerningValue:CGFloat, text:String, fontSize:CGFloat) -> (NSAttributedString){
        return NSAttributedString(string: text ?? "", attributes: [NSKernAttributeName:kerningValue, NSForegroundColorAttributeName:UIColor(red: 53/255, green: 53/255, blue: 53/255, alpha: 1)])
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.cellName.tag = 101
        self.cellName.marqueeType = MarqueeType.MLContinuous
        self.cellName.scrollDuration = 9.0
        self.cellName.animationCurve = UIViewAnimationOptions.CurveEaseInOut
        self.cellName.fadeLength = 2.0
        self.cellName.leadingBuffer = 0
        self.cellName.trailingBuffer = 0
        self.longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(CustomCell.longPress(_:)))
        self.longPressRecognizer.minimumPressDuration = 0.45
        self.addGestureRecognizer(longPressRecognizer)
        self.cellNameFrame = cellName.frame
        self.cellTimeFrame = cellTime.frame
        self.colourIndicator.layer.cornerRadius = self.colourIndicator.frame.width/2
    }
    
    func longPress(sender:UILongPressGestureRecognizer)
    {
        if sender.state == UIGestureRecognizerState.Began
        {
            self.delegate!.touchHeld!(self.item)
        }
    }
    
    func changeColour()
    {
        if self.selected == true
        {
            if cellName.textColor != UIColor(red: 245/255, green: 112/255, blue: 71/255, alpha: 1)
            {
                cellName.textColor = tintColour
                cellTime.textColor = tintColour
            }
        }
        else
        {
            cellName.textColor = UIColor.blackColor()
            cellTime.textColor = UIColor.blackColor()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        cellName.textColor = UIColor(red: 245/255, green: 112/255, blue: 71/255, alpha: 1)
        cellTime.textColor = UIColor(red: 245/255, green: 112/255, blue: 71/255, alpha: 1)
        self.delegate!.touchBegan!(self.item)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.cellName.textColor = UIColor.blackColor()
        self.cellTime.textColor = UIColor.blackColor()
        self.delegate!.touchCanceled!(self.item)
        super.touchesCancelled(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.cellName.textColor = UIColor.blackColor()
        self.cellTime.textColor = UIColor.blackColor()
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if initialSkip == false 
        {
            self.changeColour()
        }
        initialSkip = false
    }
    
    @IBAction func rescheduleButtonPressed(sender: UIButton) {
        //call delegate to open the reschedule screen
        self.cellDelegate.presentGridMenuView(.reschedule)
    }
    
    @IBAction func reminderButtonPressed(sender: UIButton) {
        //call the delegate to pull up the reminder screen
        
        self.cellDelegate.presentGridMenuView(.reminder)
        
        let alert = DoAlertView()
        alert.nAnimationType = 3
        alert.dRound = 5
        alert.bDestructive = false
        alert.nContentMode = 3
        alert.doYesNo("Set Reminder", body: "", yes: {(alertView) in
            var didFindReminder:Bool = false
            let app:UIApplication = UIApplication.sharedApplication()
            for oneEvent in app.scheduledLocalNotifications! {
                let notification = oneEvent as UILocalNotification
                let userInfoCurrent = notification.userInfo! as! [String:AnyObject]
                let uid = userInfoCurrent["uid"]! as! String
                if uid == (self.item as! Task).name! {
                    app.cancelLocalNotification(notification)
                    let localNotification:UILocalNotification = UILocalNotification()
                    localNotification.alertBody = "\((self.item as! Task).name!)"
                    localNotification.fireDate = alertView.datePicker.date
                    localNotification.userInfo = ["uid":(self.item as! Task).name!]
                    localNotification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                    didFindReminder = true
                    break;
                }
            }
            if didFindReminder == false
            {
                let localNotification:UILocalNotification = UILocalNotification()
                localNotification.alertBody = "\((self.item as! Task).name!)"
                localNotification.fireDate = alertView.datePicker.date
                localNotification.userInfo = ["uid":(self.item as! Task).name!]
                localNotification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            }
            self.reminderButton.selected = true
            (self.item as! Task).hasReminder = true
            self.cellDelegate.dismissedAlertView()
            }, no: {(alertView) in
                let app:UIApplication = UIApplication.sharedApplication()
                for oneEvent in app.scheduledLocalNotifications! {
                    let notification = oneEvent as UILocalNotification
                    let userInfoCurrent = notification.userInfo! as! [String:AnyObject]
                    let uid = userInfoCurrent["uid"]! as! String
                    if uid == (self.item as! Task).name! {
                        app.cancelLocalNotification(notification)
                        break;
                    }
                }
                self.cellDelegate.dismissedAlertView()
                (self.item as! Task).hasReminder = false
                self.reminderButton.selected = false
        })
    }
    
    @IBAction func repeatButtonPressed(sender: UIButton) {
        //tell the delegate to open the repeat screen
        (self.cellDelegate as! ViewController).isCreatingTask = false
        self.cellDelegate.presentGridMenuView(GridPresentationType.repeating)
    }
    
}
