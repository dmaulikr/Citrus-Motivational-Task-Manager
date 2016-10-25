//
//  SettingsTableViewCell.swift
//  Citrus
//
//  Created by Dilraj Devgun on 7/29/15.
//  Copyright © 2015 Clockwork Development, LLC. All rights reserved.
//

import UIKit

enum SettingsDetailViewType:Int
{
    case none = 0
    case scroller
    case slider
    case colorPicker
    
}

protocol SettingsTableViewCellDelegate
{
    func presentGridView()
}

class SettingsTableViewCell: UITableViewCell, LTInfiniteScrollViewDataSource, LTInfiniteScrollViewDelegate {

    @IBOutlet weak var settingTitle: UILabel!
    @IBOutlet weak var detailView: UIView!
    var detailViewType:SettingsDetailViewType!
    var timeScrollerView:LTInfiniteScrollView!
    var valueAdded = 0
    var segment = 2000
    let rewardsManager = RewardSystemManager.sharedInstance
    var timeLabel:UILabel!
    var isInitialAllocation = true
    var cellDelegate:SettingsTableViewCellDelegate!
    var colors = [UIColor(red: 80/255, green: 176/255, blue: 252/255, alpha: 1), UIColor(red: 254/255, green: 215/255, blue: 79/255, alpha: 1), UIColor(red: 126/255, green: 209/255, blue: 95/255, alpha: 1), UIColor(red: 255/255, green: 129/255, blue: 74/255, alpha: 1), UIColor(red: 255/255, green: 82/255, blue: 60/255, alpha: 1)]
    var catViews:[UIView] = []
    var taskViews:[UIView] = []
    
    
    var catRedBase:CGFloat = 80
    var catGreenBase:CGFloat = 176
    var catBlueBase:CGFloat = 252
    
    var taskRedBase:CGFloat = 254
    var taskGreenBase:CGFloat = 215
    var taskBlueBase:CGFloat = 79

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        let goal = rewardsManager.getGoal()
        self.valueAdded = segment*goal
    }

    func kern(kerningValue:CGFloat, text:String, fontSize:CGFloat) -> (NSAttributedString){
        let font = UIFont(name: "Bariol-Regular", size: fontSize)
        return NSAttributedString(string: text ?? "", attributes: [NSKernAttributeName:kerningValue, NSForegroundColorAttributeName:UIColor(red: (255/255), green: (148/255), blue: (87/255), alpha: 1), NSFontAttributeName:font!])
    }
    
    func setUpButtonText(){
        self.settingTitle.attributedText = self.kern(2.5, text: self.settingTitle.text!, fontSize: 20)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupDetailView()
    {
        if isInitialAllocation == false
        {
            switch self.detailViewType.rawValue
            {
                case 1: self.createScroller()
                case 2: self.createSwitch()
                case 3: self.createColorPickerView()
                default:break
            }
        }
        else
        {
            isInitialAllocation = false
        }
    }
    
    func createColorPickerView()
    {
        let upperView = UIView(frame: CGRectMake(0, 0, self.frame.width, 40))
        let lowerView = UIView(frame: CGRectMake(0, 60, self.frame.width, 60))
        let catLabel = UILabel()
        catLabel.text = "Category:"
        catLabel.font = UIFont(name: "Bariol-Regular", size: 18)
        catLabel.sizeToFit()
        catLabel.frame = CGRectMake(30, 7, catLabel.frame.width, catLabel.frame.height)
        upperView.addSubview(catLabel)
        let taskLabel = UILabel()
        taskLabel.text = "Task:"
        taskLabel.font = UIFont(name: "Bariol-Regular", size: 18)
        taskLabel.sizeToFit()
        taskLabel.frame = CGRectMake(30, 7, taskLabel.frame.width, taskLabel.frame.height)
        lowerView.addSubview(taskLabel)
        let blockWidth:CGFloat = ((self.frame.width)-CGFloat(110)-catLabel.frame.width)/5
        for x in 0 ..< 2
        {
            for y in 0 ..< 5
            {
                let colourView = UIView()
                colourView.frame = CGRectMake((catLabel.frame.maxX + CGFloat(10))+(blockWidth * CGFloat(y)) + CGFloat(10*y), 0, blockWidth, blockWidth)
                colourView.backgroundColor = self.colors[y]
                colourView.layer.cornerRadius = blockWidth/2
                colourView.tag = (x*10)+y
        
                
                let taprecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsTableViewCell.tappedColour(_:)))
                taprecognizer.numberOfTapsRequired = 1
                colourView.addGestureRecognizer(taprecognizer)
                if x == 0
                {
                    let standardUserDefaults = NSUserDefaults.standardUserDefaults()
                    
                    let r = standardUserDefaults.valueForKey("catRedBase") as! CGFloat
                    let g = standardUserDefaults.valueForKey("catGreenBase") as! CGFloat
                    let b = standardUserDefaults.valueForKey("catBlueBase") as! CGFloat
                    let tempColor = CIColor(color: self.colors[y])
                    let red = tempColor.red
                    let green = tempColor.green
                    let blue = tempColor.blue
                    if r/255 == red && g/255 == green && b/255 == blue
                    {
                        colourView.layer.borderWidth = 2
                        colourView.layer.borderColor = UIColor.blackColor().CGColor
                    }
                    upperView.addSubview(colourView)
                    catViews.append(colourView)
                }
                else
                {
                    let standardUserDefaults = NSUserDefaults.standardUserDefaults()
                    
                    let r = standardUserDefaults.valueForKey("taskRedBase") as! CGFloat
                    let g = standardUserDefaults.valueForKey("taskGreenBase") as! CGFloat
                    let b = standardUserDefaults.valueForKey("taskBlueBase") as! CGFloat
                    let tempColor = CIColor(color: self.colors[y])
                    let red = tempColor.red
                    let green = tempColor.green
                    let blue = tempColor.blue
                    if r/255 == red && g/255 == green && b/255 == blue
                    {
                        colourView.layer.borderWidth = 2
                        colourView.layer.borderColor = UIColor.blackColor().CGColor
                    }
                    lowerView.addSubview(colourView)
                    taskViews.append(colourView)
                }
            }
        }
        self.detailView.addSubview(upperView)
        self.detailView.addSubview(lowerView)
        
    }
    
    func tappedColour(sender:UITapGestureRecognizer)
    {
        let num = sender.view!.tag
        
        let temp:Int = num/10
        
        if temp == 1
        {
            for v in taskViews
            {
                v.layer.borderWidth = 0
                v.layer.borderColor = UIColor.clearColor().CGColor
            }
            sender.view?.layer.borderColor = UIColor.blackColor().CGColor
            sender.view?.layer.borderWidth = 2
        }
        else
        {
            for v in catViews
            {
                v.layer.borderWidth = 0
                v.layer.borderColor = UIColor.clearColor().CGColor
            }
            sender.view?.layer.borderColor = UIColor.blackColor().CGColor
            sender.view?.layer.borderWidth = 2
        }
        
        
        let standardUserDefaults = NSUserDefaults.standardUserDefaults()
        switch num{
            case 0:
                standardUserDefaults.setValue(80, forKey: "catRedBase")
                standardUserDefaults.setValue(176, forKey: "catGreenBase")
                standardUserDefaults.setValue(252, forKey: "catBlueBase")
                standardUserDefaults.setValue(191, forKey: "catRedLimit")
                standardUserDefaults.setValue(222, forKey: "catGreenLimit")
                standardUserDefaults.setValue(254, forKey: "catBlueLimit")
            case 1:
                standardUserDefaults.setValue(254, forKey: "catRedBase")
                standardUserDefaults.setValue(215, forKey: "catGreenBase")
                standardUserDefaults.setValue(79, forKey: "catBlueBase")
                standardUserDefaults.setValue(255, forKey: "catRedLimit")
                standardUserDefaults.setValue(242, forKey: "catGreenLimit")
                standardUserDefaults.setValue(191, forKey: "catBlueLimit")
            case 2:
                standardUserDefaults.setValue(126, forKey: "catRedBase")
                standardUserDefaults.setValue(209, forKey: "catGreenBase")
                standardUserDefaults.setValue(95, forKey: "catBlueBase")
                standardUserDefaults.setValue(212, forKey: "catRedLimit")
                standardUserDefaults.setValue(245, forKey: "catGreenLimit")
                standardUserDefaults.setValue(176, forKey: "catBlueLimit")
            case 3:
                standardUserDefaults.setValue(255, forKey: "catRedBase")
                standardUserDefaults.setValue(129, forKey: "catGreenBase")
                standardUserDefaults.setValue(74, forKey: "catBlueBase")

                standardUserDefaults.setValue(255, forKey: "catRedLimit")
                standardUserDefaults.setValue(220, forKey: "catGreenLimit")
                standardUserDefaults.setValue(179, forKey: "catBlueLimit")
            case 4:
                standardUserDefaults.setValue(255, forKey: "catRedBase")
                standardUserDefaults.setValue(82, forKey: "catGreenBase")
                standardUserDefaults.setValue(60, forKey: "catBlueBase")
                
                standardUserDefaults.setValue(255, forKey: "catRedLimit")
                standardUserDefaults.setValue(175, forKey: "catGreenLimit")
                standardUserDefaults.setValue(164, forKey: "catBlueLimit")
            case 10:
                standardUserDefaults.setValue(80, forKey: "taskRedBase")
                standardUserDefaults.setValue(176, forKey: "taskGreenBase")
                standardUserDefaults.setValue(252, forKey: "taskBlueBase")
                standardUserDefaults.setValue(191, forKey: "taskRedLimit")
                standardUserDefaults.setValue(222, forKey: "taskGreenLimit")
                standardUserDefaults.setValue(254, forKey: "taskBlueLimit")
            case 11:
                standardUserDefaults.setValue(254, forKey: "taskRedBase")
                standardUserDefaults.setValue(215, forKey: "taskGreenBase")
                standardUserDefaults.setValue(79, forKey: "taskBlueBase")
                standardUserDefaults.setValue(255, forKey: "taskRedLimit")
                standardUserDefaults.setValue(242, forKey: "taskGreenLimit")
                standardUserDefaults.setValue(191, forKey: "taskBlueLimit")
            case 12:
                standardUserDefaults.setValue(126, forKey: "taskRedBase")
                standardUserDefaults.setValue(209, forKey: "taskGreenBase")
                standardUserDefaults.setValue(95, forKey: "taskBlueBase")
                standardUserDefaults.setValue(212, forKey: "taskRedLimit")
                standardUserDefaults.setValue(245, forKey: "taskGreenLimit")
                standardUserDefaults.setValue(176, forKey: "taskBlueLimit")
            case 13:
                standardUserDefaults.setValue(255, forKey: "taskRedBase")
                standardUserDefaults.setValue(129, forKey: "taskGreenBase")
                standardUserDefaults.setValue(74, forKey: "taskBlueBase")

                standardUserDefaults.setValue(255, forKey: "taskRedLimit")
                standardUserDefaults.setValue(220, forKey: "taskGreenLimit")
                standardUserDefaults.setValue(179, forKey: "taskBlueLimit")
            case 14:
                standardUserDefaults.setValue(255, forKey: "taskRedBase")
                standardUserDefaults.setValue(82, forKey: "taskGreenBase")
                standardUserDefaults.setValue(60, forKey: "taskBlueBase")
                standardUserDefaults.setValue(255, forKey: "taskRedLimit")
                standardUserDefaults.setValue(175, forKey: "taskGreenLimit")
                standardUserDefaults.setValue(164, forKey: "taskBlueLimit")
            default:
                print("no colour")
        }
    }
    
    func createScroller(){
        timeLabel = UILabel()
        timeLabel.font = UIFont(name: "Bariol-Regular", size: 18)
        timeLabel.textColor = UIColor(red: (255/255), green: (148/255), blue: (87/255), alpha: 1)
        timeLabel.text = "\(self.rewardsManager.getGoal()) tasks"
        timeLabel.sizeToFit()
        timeLabel.frame = CGRectMake((self.frame.width/2)-(self.timeLabel.frame.width/2), 10, self.timeLabel.frame.width, 20)
        self.timeScrollerView = LTInfiniteScrollView(frame: CGRectMake(0, self.timeLabel.frame.maxY+8, self.frame.width, 50))
        timeScrollerView.delegate = self
        timeScrollerView.dataSource = self
        timeScrollerView.maxScrollDistance = 60
        self.detailView.addSubview(self.timeLabel)
        self.detailView.addSubview(self.timeScrollerView)
        self.timeScrollerView.reloadData()
        timeScrollerView.num = self.rewardsManager.getGoal()*self.segment
    }
    
    func setValueForScroller()
    {
        self.timeScrollerView.num = self.rewardsManager.getGoal()*self.segment
        self.timeLabel.text = "\(self.rewardsManager.getGoal()) tasks"
        self.timeLabel.sizeToFit()
    }
    
    enum TimeOperation
    {
        case Add
        case Subtract
    }
    
    func numberOfViews() -> Int {
        return 5000000
    }
    
    func numberOfVisibleViews() -> Int {
        return 41
    }
    
    func viewAtIndex(index: Int, reusingView view: UIView!) -> UIView! {
        if view != nil
        {
            return view
        }
        let testFrame = CGRectMake(0, 0, 2, self.timeScrollerView.frame.height)
        let imageView = UIImageView(image: UIImage(named: "wheel line"))
        imageView.frame = testFrame
        imageView.contentMode = UIViewContentMode.ScaleToFill
        return imageView
    }
    
    func updateView(scrollDirection: ScrollDirection, num: Int) {
        self.valueAdded = num
        if scrollDirection.rawValue == 0
        {
            self.updateGoal(TimeOperation.Subtract)
        }
        else
        {
            self.updateGoal(TimeOperation.Add)
        }
    }
    
    func updateGoal(op:TimeOperation)
    {
        let value = self.valueAdded/self.segment
        self.timeLabel.text = "\(value) tasks"
        self.timeLabel.sizeToFit()
        if !(value <= 0)
        {
            self.rewardsManager.setGoal(value)
        }
    }
    
    func createSwitch(){
        let notificationSwitch = UISwitch()
        
        if UIApplication.sharedApplication().respondsToSelector(#selector(UIApplication.currentUserNotificationSettings)) == true
        {
            let grantedSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
            if grantedSettings?.types.contains(UIUserNotificationType.Alert) == true
            {
                notificationSwitch.setOn(true, animated: false)
            }
            else
            {
                notificationSwitch.setOn(false, animated: false)
            }
        }
        notificationSwitch.frame = CGRectMake((self.frame.width/2)-(notificationSwitch.frame.width/2), 35, notificationSwitch.frame.height, notificationSwitch.frame.height)
        notificationSwitch.addTarget(self, action: #selector(SettingsTableViewCell.switchChangedValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.detailView.addSubview(notificationSwitch)
    }
    
    func switchChangedValue(switcher:UISwitch)
    {
        if switcher.on == true
        {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        }
        else
        {
            switcher.setOn(true, animated: true)
            if cellDelegate != nil
            {
                self.cellDelegate.presentGridView()
            }
        }
    }

}
