//
//  ViewController.swift
//  Citrus
//
//  Created by Dilraj Devgun on 4/5/15.
//  Copyright (c) 2015 Clockwork Development, LLC. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox

class ViewController: UIViewController, XYPieChartDelegate, XYPieChartDataSource, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, LTInfiniteScrollViewDataSource, LTInfiniteScrollViewDelegate, InputAccessoryViewDelegate, SettingsViewControllerDelegate, CustomCellDelegate, CNPGridMenuDelegate{

    
    var date:NSDate!
    
    //outlets
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var dateButton: UIBarButtonItem!
    @IBOutlet weak var reminderButtonForInputView: UIButton!
    @IBOutlet weak var repeatButtonForInputView: UIButton!
    @IBOutlet weak var pieChartContainerView: UIView! //the base view for the rest of the frames. Made in storyboard
    @IBOutlet weak var tableView: UITableView!
    var pieChartView:XYPieChart! //category piechart
    var pieChartTaskView:XYPieChart! //task pie chart
    var pieChartTaskContainerView:UIView! //the container of the task pie chart
    var originalPieChartFrame:CGRect! //the original frame of the category pie chart
    var imgView:UIImageView = UIImageView() //the image of the pie chart
    var encapsulatingView:UIView! //view used to ecapsulate the pie chart for an image. Also holds the category pie chart
    
    //Tasks and Category Variables
    var placeHolderCell:CustomCell!
    var pullDownInProgress = false
    var selectedFromTableView:Bool = false
    var isTasks:Bool = false
    var categories:[Category]!
    var selectedCategory:Category!
    var tasks:[Task]!
    var itemManager = ItemManager.sharedInstance
    var selectedIndex:Int = -1
    var selectedIndexPath:NSIndexPath!
    
    //colour limits
    //categories
    //blue
    var catRedBase:CGFloat = 80
    var catRedLimit:CGFloat = 191
    var catGreenBase:CGFloat = 176
    var catGreenLimit:CGFloat = 222
    var catBlueBase:CGFloat = 252
    var catBlueLimit:CGFloat = 254
    
    var taskRedBase:CGFloat = 254
    var taskRedLimit:CGFloat = 255
    var taskGreenBase:CGFloat = 215
    var taskGreenLimit:CGFloat = 242
    var taskBlueBase:CGFloat = 79
    var taskBlueLimit:CGFloat = 191


    
    override func viewDidLoad() {
        super.viewDidLoad()
        let components = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: NSDate())
        self.date = NSCalendar.currentCalendar().dateFromComponents(components)
        self.categories = self.itemManager.getCategoriesForDate(self.date)
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(13, forBarMetrics: UIBarMetrics.Default)
        self.settingsButton.setBackgroundVerticalPositionAdjustment(13, forBarMetrics: UIBarMetrics.Default)
        self.dateButton.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 13), forBarMetrics: UIBarMetrics.Default)
        UIApplication.sharedApplication().statusBarHidden = true
        UINavigationBar.appearance().shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.placeHolderCell = (self.tableView.dequeueReusableCellWithIdentifier("cell") as! CustomCell)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        //FIX VERTICAL POSITION OF BAR BUTTON ITEM
        let day = components.day
        self.setTitleForDate()
        dateButton.title = "\(day)"
        let font = UIFont(name: "Bariol-Regular", size: 32)
        dateButton.setTitleTextAttributes([NSFontAttributeName:font!, NSForegroundColorAttributeName:UIColor(red: 245/255, green: 112/255, blue: 71/255, alpha: 1), NSKernAttributeName: 50], forState: UIControlState.Normal)
        self.navigationItem.rightBarButtonItem?.setTitlePositionAdjustment(UIOffset(horizontal: -8, vertical: 18), forBarMetrics: .Default)
        self.navigationItem.leftBarButtonItem?.setTitlePositionAdjustment(UIOffset(horizontal: 10, vertical: 18), forBarMetrics: .Default)
        
        
        
        self.setUpColors()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        //self.tableView.backgroundView?.backgroundColor = UIColor(red: 253/255, green: 251/255, blue: 241/255, alpha: 1)
        self.tableView.backgroundColor = UIColor(red: (253/255), green: (251/255), blue: (241/255), alpha: 1)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if pieChartView == nil
        {
            self.encapsulatingView = UIView(frame: CGRectMake(self.pieChartContainerView.frame.minX - 10, self.pieChartContainerView.frame.minY - 10, self.pieChartContainerView.frame.width+20, self.pieChartContainerView.frame.width+20))
            pieChartView = XYPieChart(frame: CGRectMake(10, 10, self.pieChartContainerView.frame.width, self.pieChartContainerView.frame.width))
            self.createPieChartView(true, view: self.pieChartView)
            self.encapsulatingView.addSubview(self.pieChartView)
            self.view.addSubview(encapsulatingView)
            self.pieChartTaskContainerView = UIView(frame: CGRectMake(self.pieChartContainerView.frame.minX+60, self.pieChartContainerView.frame.minY+23, self.pieChartContainerView.frame.width*0.9, self.self.pieChartContainerView.frame.height*0.9))
            self.view.insertSubview(self.pieChartTaskContainerView, belowSubview: self.self.encapsulatingView)
            self.originalPieChartFrame = self.pieChartContainerView.frame
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        let components = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: NSDate())
        let day = components.day
        dateButton.title = "\(day)"
        self.initialSetupForItemCreation()
        self.selectedIndex = -1
        self.tableView.reloadData()
        self.setUpColors()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.categories = self.itemManager.getCategoriesForDate(self.date)
        if isTasks == true
        {
            self.tasks = self.itemManager.getTasksInCategoryForDate(self.selectedCategory, date: self.date)
            self.pieChartTaskView.reloadData()
        }
        else
        {
            self.categories = self.itemManager.getCategoriesForDate(self.date)
            self.pieChartView.reloadData()
        }
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpColors(){
        let standardUserDefaults = NSUserDefaults.standardUserDefaults()
        self.catRedBase = standardUserDefaults.valueForKey("catRedBase") as! CGFloat
        self.catGreenBase = standardUserDefaults.valueForKey("catGreenBase") as! CGFloat
        self.catBlueBase = standardUserDefaults.valueForKey("catBlueBase") as! CGFloat
        
        self.catRedLimit = standardUserDefaults.valueForKey("catRedLimit") as! CGFloat
        self.catGreenLimit = standardUserDefaults.valueForKey("catGreenLimit") as! CGFloat
        self.catBlueLimit = standardUserDefaults.valueForKey("catBlueLimit") as! CGFloat
        
        self.taskRedBase = standardUserDefaults.valueForKey("taskRedBase") as! CGFloat
        self.taskGreenBase = standardUserDefaults.valueForKey("taskGreenBase") as! CGFloat
        self.taskBlueBase = standardUserDefaults.valueForKey("taskBlueBase") as! CGFloat
        
        self.taskRedLimit = standardUserDefaults.valueForKey("taskRedLimit") as! CGFloat
        self.taskGreenLimit = standardUserDefaults.valueForKey("taskGreenLimit") as! CGFloat
        self.taskBlueLimit = standardUserDefaults.valueForKey("taskBlueLimit") as! CGFloat
    }
    
    func setTitleForDate()
    {
        let components = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: NSDate())
        let todaysDate = NSCalendar.currentCalendar().dateFromComponents(components)
        
        var stringForTitle = ""
        
        if todaysDate?.compare(self.date) == NSComparisonResult.OrderedSame
        {
            stringForTitle = "TODAY"
        }
        else
        {
            let dateformatter = NSDateFormatter()
            dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateformatter.timeStyle = NSDateFormatterStyle.NoStyle
            stringForTitle = dateformatter.stringFromDate(self.date)
        }
        
        let titleLabel = UILabel()
        titleLabel.attributedText = NSAttributedString(string: stringForTitle, attributes: [NSKernAttributeName:2.4, NSFontAttributeName:UIFont.systemFontOfSize(20), NSForegroundColorAttributeName:UIColor.blackColor()])
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
    
    func numberOfSlicesInPieChart(pieChart: XYPieChart!) -> UInt {
        //returns number of items
        if isTasks == true
        {
            return UInt(self.tasks.count)
        }
        else
        {
            return UInt(self.categories.count)
        }
        
    }
    
    //MARK pie chart delegate
    func pieChart(pieChart: XYPieChart!, colorForSliceAtIndex index: UInt) -> UIColor! {
        if self.isTasks == true{
            let idx:CGFloat = CGFloat(index)
            let redincrement:CGFloat = (taskRedLimit - taskRedBase)/CGFloat(self.tasks.count)
            let greenincrement:CGFloat = (taskGreenLimit - taskGreenBase)/CGFloat(self.tasks.count)
            let blueincrement:CGFloat = (taskBlueLimit - taskBlueBase)/CGFloat(self.tasks.count)
            return UIColor(red:(taskRedBase + (idx*redincrement))/255, green: (taskGreenBase + (idx*greenincrement))/255, blue: (taskBlueBase + (idx*blueincrement))/255, alpha: 1)
        }
        else{
            let idx:CGFloat = CGFloat(index)
            let redincrement:CGFloat = (catRedLimit - catRedBase)/CGFloat(self.categories.count)
            let greenincrement:CGFloat = (catGreenLimit - catGreenBase)/CGFloat(self.categories.count)
            let blueincrement:CGFloat = (catBlueLimit - catBlueBase)/CGFloat(self.categories.count)
            return UIColor(red:(catRedBase + (idx*redincrement))/255, green: (catGreenBase + (idx*greenincrement))/255, blue: (catBlueBase + (idx*blueincrement))/255, alpha: 1)
        }
    }
    
    func pieChart(pieChart: XYPieChart!, valueForSliceAtIndex index: UInt) -> CGFloat {
        //returns the value in time for the segment
        if isTasks == true
        {
            return CGFloat(self.tasks[Int(index)].hours*60) + CGFloat(self.tasks[Int(index)].minutes)
        }
        else
        {
            return CGFloat(self.categories[Int(index)].hours*60) + CGFloat(self.categories[Int(index)].minutes)
        }
        
    }
    
    func pieChart(pieChart: XYPieChart!, didDeselectSliceAtIndex index: UInt) {
        //deselects the tableview at the corresponding index
        self.selectedIndex = -1
        if isTasks == true
        {
            let section:Int = 0
            let ind:Int = Int(index)
            let path: NSIndexPath = NSIndexPath(forRow:ind, inSection: section)
            self.tableView.deselectRowAtIndexPath(path, animated: true)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
    }
    
    //*********************************************************************************************************FIX SELECTION FOR THE CASE WHERE THE USER SELECTS THROUGH THE TABLE VIEW AND THEN DECIDES TO DESELECT THROUGH THE PIE CHART   *********************************************************************************************************
    
    func pieChart(pieChart: XYPieChart!, willSelectSliceAtIndex index: UInt) {
        //checks to deselect an index in the piechart depending on a previous selection
        let currentlySelectedIndex = tableView.indexPathForSelectedRow
        if let prev = currentlySelectedIndex
        {
            if Int(index) != Int(prev.row)
            {
                if isTasks == true
                {
                    self.pieChartTaskView.setSliceDeselectedAtIndex(prev.row)
                    self.selectedIndex = -1
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
                else
                {
                    self.pieChartView.setSliceDeselectedAtIndex(prev.row)
                    self.selectedIndex = -1
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
            }
            else
            {
                if isTasks == true
                {
                    self.pieChartTaskView.setSliceDeselectedAtIndex(Int(index))
                    self.selectedIndex = -1
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
                else
                {
                    self.pieChartView.setSliceDeselectedAtIndex(Int(index))
                    self.selectedIndex = -1
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
            }
        }
    }
    
    func pieChart(pieChart: XYPieChart!, didSelectSliceAtIndex index: UInt) {
        //selects a segment in the tableview
        let section:Int = 0
        let ind:Int = Int(index)
        let path: NSIndexPath = NSIndexPath(forRow: ind, inSection: section)
        self.tableView.selectRowAtIndexPath(path, animated: true, scrollPosition: UITableViewScrollPosition.Top)
        self.didSelectItem(Int(index))
    }
    
    func pieChart(pieChart: XYPieChart!, touchHeldAtIndex index: Int) {
        if isTasks == true
        {
            self.oldItem = self.tasks[index]
        }
        else
        {
            self.oldItem = self.categories[index]
        }
        UIView.animateWithDuration(0.3, animations: {() in
            self.encapsulatingView.alpha = 0
            self.imgView.alpha = 0
            self.pieChartTaskContainerView.alpha = 0
            self.tableView.alpha = 0
        })
        self.animateView(false)
    }
    
    //MARK tableview delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //returns 1 as the number of tableview sections
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //returns a custom cell
        if isTasks == true
        {
            let tbvc: CustomCell = (tableView.dequeueReusableCellWithIdentifier("cell") as! CustomCell)
            let name = self.tasks[indexPath.row].name
            var time:String
            if self.tasks[indexPath.row].hours == 0{
                time = "\(self.tasks[indexPath.row].minutes)m"
            }
            else if self.tasks[indexPath.row].minutes == 0{
                time = "\(self.tasks[indexPath.row].hours)h"
            }
            else{
                time = "\(self.tasks[indexPath.row].hours)h & \(self.tasks[indexPath.row].minutes)m"
            }
            tbvc.setValuesForCell(name!, time: time)
            tbvc.num = indexPath.row
            tbvc.item = self.tasks[indexPath.row]
            tbvc.delegate = self
            tbvc.autoresizingMask = UIViewAutoresizing.FlexibleHeight
            tbvc.clipsToBounds = true
            tbvc.buttonContainerView.hidden = false
            tbvc.setColourForIndicator(self.pieChart(self.pieChartView, colorForSliceAtIndex: UInt(indexPath.row)))
            tbvc.cellDelegate = self
            tbvc.setUpButton()
            return tbvc
        }
        else 
        {
            let tbvc: CustomCell = (tableView.dequeueReusableCellWithIdentifier("cell") as! CustomCell)
            let name = self.categories[indexPath.row].name
            var time:String
            if self.categories[indexPath.row].hours == 0{
                time = "\(self.categories[indexPath.row].minutes)m"
            }
            else if self.categories[indexPath.row].minutes == 0{
                time = "\(self.categories[indexPath.row].hours)h"
            }
            else{
                time = "\(self.categories[indexPath.row].hours)h & \(self.categories[indexPath.row].minutes)m"
            }
            tbvc.setValuesForCell(name, time: time)
            tbvc.num = indexPath.row
            tbvc.item = self.categories[indexPath.row]
            tbvc.delegate = self
            tbvc.buttonContainerView.hidden = true
            tbvc.setColourForIndicator(self.pieChart(self.pieChartView, colorForSliceAtIndex: UInt(indexPath.row)))
            return tbvc
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.selectedIndex != -1
        {
            if self.selectedIndex == indexPath.row
            {
                return 145
            }
        }
        return 85
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //returns the number of indexes for the tableview
        if isTasks == true
        {
            return self.tasks.count
        }
        else
        {
            return self.categories.count
        }
        
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        //deselects a tableview piece and pie chart segments if the one selected is the same as the previously selected index
        let currentlySelectedIndex = tableView.indexPathForSelectedRow
        if let prev = currentlySelectedIndex
        {
            if indexPath.row == prev.row
            {
                if isTasks == true
                {
                    self.pieChartTaskView.setSliceDeselectedAtIndex(prev.row)
                    self.selectedIndex = -1
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
                else
                {
                    self.pieChartTaskView.setSliceDeselectedAtIndex(prev.row)
                }
                self.tableView.deselectRowAtIndexPath(prev, animated: true)
                return nil
            }
        }
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //handle pie chart selection
        if isTasks == true
        {
            self.pieChartTaskView.setSliceSelectedAtIndex(indexPath.row)
        }
        else
        {
            self.pieChartView.setSliceSelectedAtIndex(indexPath.row)
        }
        self.didSelectItem(indexPath.row)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        //deselects the pie chart
        if isTasks == true
        {
            self.pieChartTaskView.setSliceDeselectedAtIndex(indexPath.row)
            self.selectedIndex = -1
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        else
        {
            self.pieChartView.setSliceDeselectedAtIndex(indexPath.row)
        }
    }
    
    func touchHeld(object: NSManagedObject!) {
        self.oldItem = object
        self.tableView.userInteractionEnabled = false
        UIView.animateWithDuration(0.3, animations: {() in
            self.encapsulatingView.alpha = 0
            self.imgView.alpha = 0
            self.pieChartTaskContainerView.alpha = 0
            self.tableView.alpha = 0
        })
        self.animateView(false)
    }
    
    func touchBegan(object: NSManagedObject!) {
        var index:Int = -1
        if isTasks == true
        {
            for i in 0 ..< tasks.count
            {
                if tasks[i] == (object as! Task)
                {
                    index = i
                }
            }
            if index != -1
            {
                self.pieChartTaskView.setSliceSelectedAtIndex(index)
            }
        }
        else
        {
            for i in 0 ..< categories.count
            {
                if categories[i] == (object as! Category)
                {
                    index = i
                }
            }
            if index != -1
            {
                self.pieChartView.setSliceSelectedAtIndex(index)
            }
        }
    }
    
    func touchCanceled(object: NSManagedObject!) {
        var index:Int = -1
        if isTasks == true
        {
            for i in 0 ..< tasks.count
            {
                if tasks[i] == (object as! Task)
                {
                    index = i
                }
            }
            if index != -1
            {
                self.pieChartTaskView.setSliceDeselectedAtIndex(index)
            }
        }
        else
        {
            for i in 0 ..< categories.count
            {
                if categories[i] == (object as! Category)
                {
                    index = i
                }
            }
            if index != -1
            {
                self.pieChartView.setSliceDeselectedAtIndex(index)
            }
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //handles the pull down to add new item
        pullDownInProgress = scrollView.contentOffset.y <= 0.0
        if pullDownInProgress
        {
            tableView.insertSubview(placeHolderCell, atIndex: 0)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //handles the pull down to add new item
        let scrollViewContentOffsetY = scrollView.contentOffset.y
        if pullDownInProgress && scrollView.contentOffset.y <= 0.0
        {
            placeHolderCell.frame = CGRect(x: 0, y: -85, width:tableView.frame.size.width, height: 85)
            placeHolderCell.cellName.text = -scrollViewContentOffsetY > 85/1.5  ? "Release to add item" : "Pull to add item"
            placeHolderCell.cellTime.text = ""
            placeHolderCell.alpha = min(1.0, -scrollViewContentOffsetY / (85/1.5))
            placeHolderCell.buttonContainerView.hidden = true
            self.encapsulatingView.alpha = max(0, 1+scrollViewContentOffsetY / (85/1.5))
            self.imgView.alpha = max(0, 1+scrollViewContentOffsetY / (85/1.5))
            self.pieChartTaskContainerView.alpha = max(0, 1+scrollViewContentOffsetY / (85/1.5))
        }
        else
        {
            pullDownInProgress = false
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //handles the pull down to add new item
        if pullDownInProgress && -scrollView.contentOffset.y > 85/1.5
        {
            self.tableView.alpha = 0
            self.animateView(true)
        }
        else
        {
            self.tableView.alpha = 1
            self.encapsulatingView.alpha = 1
            self.imgView.alpha = 1
            self.pieChartTaskContainerView.alpha = 1
        }
        pullDownInProgress = false
    }
    
    func animateView(new:Bool)
    {
        self.valueAdded = -53;
        self.minutes = 0;
        self.hours = 0;
        self.itemInputView.text = ""
        UIView.animateWithDuration(0.3, animations: {() in
            self.itemInputView.alpha = 1
            if self.isTasks == true
            {
                self.reminderButtonForInputView.selected = false
                self.repeatButtonForInputView.selected = false
                self.centreDot.alpha = 1
                self.timeSelectionLabel.alpha = 1
                self.timeScrollView.alpha = 1
                self.repeatButtonForInputView.alpha = 1
                self.reminderButtonForInputView.alpha = 1
            }
            else
            {
                self.itemInputView.frame = CGRectMake(self.itemInputView.frame.minX, self.originalInputY + 50, self.itemInputView.frame.width, self.itemInputView.frame.height)
            }
            })
        self.itemInputView.becomeFirstResponder()
        self.timeScrollView.reloadData()
        if new == true{
            self.isNew = true
        }
        else{
            self.isNew = false
            //set text and time for old item
            if self.oldItem?.isKindOfClass(Category.self) == true
            {
                self.itemInputView.text = (self.oldItem as! Category).name
            }
            else
            {
                self.itemInputView.text = (self.oldItem as! Task).name
                self.hours = Int((self.oldItem as! Task).hours)
                self.minutes = Int((self.oldItem as! Task).minutes)
                self.timeSelectionLabel.text = "\(hours)h \(minutes)m"
                let tempValue = (((self.hours*60)+(self.minutes))/10)*self.segment
                self.timeScrollView.num = tempValue
                self.reminderButtonForInputView.selected = (self.oldItem as! Task).hasReminder
                self.repeatButtonForInputView.selected = (self.oldItem as! Task).isRepeatable
            }
        }
    }

    func createPieChartView(categoryChart:Bool, view:XYPieChart)->()
    {
        //creates a pie chart
        view.dataSource = self
        view.delegate = self
        view.startPieAngle = CGFloat(M_PI_2)
        view.animationSpeed = 0.6
        view.showLabel = false
        view.showPercentage = false
        view.labelColor = UIColor.blackColor()
        view.setPieBackgroundColor(UIColor.clearColor())
        view.userInteractionEnabled = true
        view.moveSegment = true
        view.isCategory = categoryChart
    }
    
    @IBOutlet weak var itemInputView: UITextView!
    @IBOutlet weak var timeSelectionLabel: UILabel!
    @IBOutlet weak var centreDot: UIView!
    @IBOutlet weak var scrollerContainerView: UIView!
    var timeScrollView:LTInfiniteScrollView!
    var segment:Int = 1150
    var valueAdded:Int = -53;
    var minutes = 0;
    var hours = 0;
    var isNew:Bool!
    var oldItem:NSManagedObject?
    var originalInputY:CGFloat!
    
    func initialSetupForItemCreation()
    {
        let accessoryView = InputAccessoryView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height*0.06))
        accessoryView.delegate = self
        self.itemInputView.inputAccessoryView = accessoryView
        self.itemInputView.tintColor = UIColor.redColor()
        self.itemInputView.alpha = 0
        self.itemInputView.userInteractionEnabled = true
        self.timeSelectionLabel.alpha = 0
        self.reminderButtonForInputView.alpha = 0
        self.repeatButtonForInputView.alpha = 0
        self.timeScrollView = LTInfiniteScrollView(frame: CGRectMake(0, 0, self.scrollerContainerView.frame.width, self.scrollerContainerView.frame.height))
        self.timeScrollView.alpha = 0
        self.scrollerContainerView.addSubview(self.timeScrollView)
        self.timeScrollView.delegate = self
        self.timeScrollView.dataSource = self
        self.timeScrollView.maxScrollDistance = 30
        self.centreDot.alpha = 0
        centreDot.backgroundColor = UIColor.redColor()
        centreDot.layer.cornerRadius = self.centreDot.frame.width/2
        self.originalInputY = self.itemInputView.frame.minY
    }

    enum TimeOperation
    {
        case AddTime
        case SubtractTime
    }
    
    func numberOfViews() -> Int {
        return 5000000
    }

    func numberOfVisibleViews() -> Int {
        return 51
    }

    func viewAtIndex(index: Int, reusingView view: UIView!) -> UIView! {
        if view != nil
        {
            return view
        }
        let testFrame = CGRectMake(0, 0, 2, self.scrollerContainerView.frame.height)
        let imageView = UIImageView(image: UIImage(named: "wheel line"))
        imageView.frame = testFrame
        imageView.contentMode = UIViewContentMode.ScaleToFill
        return imageView
    }
    
    func updateView(scrollDirection: ScrollDirection, num: Int) {
        self.valueAdded = num
        if scrollDirection.rawValue == 0
        {
            self.updateTime(TimeOperation.SubtractTime)
        }
        else
        {
            self.updateTime(TimeOperation.AddTime)
        }
    }
    
    func updateTime(op:TimeOperation)
    {
        self.minutes = 10*(self.valueAdded/self.segment)
        hours = Int(self.minutes/60)
        self.minutes = self.minutes - (hours*60)
        self.timeSelectionLabel.text = "\(hours)h \(minutes)m"
    }
    
    //MARK swipe table cell
    //HANDLE THE PIE CHART RELOAD AFTER DELETION AND COMPLETION
    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    
    
    var deletedTask:NSManagedObject!
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]!
    {
        swipeSettings.transition = MGSwipeTransition.TransitionBorder
        expansionSettings.buttonIndex = 0
        if isTasks == true
        {
            if direction == MGSwipeDirection.LeftToRight
            {
                expansionSettings.fillOnTrigger = true
                expansionSettings.threshold = 1
                let pad:Int = 30
                let redColour = UIColor(red: 251/255, green: 73/255, blue: 71/255, alpha: 1.0)
                let callback:MGSwipeButtonCallback = {(sender: MGSwipeTableCell!) -> (Bool)  in
                    self.selectedIndex = -1
                    self.deletedTask = ((sender as! CustomCell).item)
                    let app:UIApplication = UIApplication.sharedApplication()
                    for oneEvent in app.scheduledLocalNotifications! {
                        let notification = oneEvent as UILocalNotification
                        let userInfoCurrent = notification.userInfo! as! [String:AnyObject]
                        let uid = userInfoCurrent["uid"]! as! String
                        if uid == self.deletedTask {
                            app.cancelLocalNotification(notification)
                            break;
                        }
                    }
                    self.itemManager.deleteTask(self.deletedTask as! Task)
                    self.tasks = self.itemManager.getTasksInCategoryForDate(self.selectedCategory, date: self.date)
                    self.pieChartTaskView.reloadData()
                    self.tableView.reloadData()
                    self.categories = self.itemManager.getCategoriesForDate(self.date)
                    return true
                }
                return [MGSwipeButton(title: "", icon: UIImage(named: "xmark"), backgroundColor: redColour, padding: pad, callback: callback)]
            }
            else
            {
                expansionSettings.fillOnTrigger = true
                expansionSettings.threshold = 1
                let greenColour = UIColor(red: 87/255, green: 199/255, blue: 107/255, alpha: 1.0)
                let pad:Int = 30
                let callback:MGSwipeButtonCallback = {(sender: MGSwipeTableCell!) -> (Bool)  in
                    self.selectedIndex = -1
                    let completedTask = ((sender as! CustomCell).item as! Task)
                    let app:UIApplication = UIApplication.sharedApplication()
                    for oneEvent in app.scheduledLocalNotifications! {
                        let notification = oneEvent as UILocalNotification
                        let userInfoCurrent = notification.userInfo! as! [String:AnyObject]
                        let uid = userInfoCurrent["uid"]! as! String
                        if uid == completedTask {
                            app.cancelLocalNotification(notification)
                            break;
                        }
                    }
                    self.itemManager.completeTaskForDate(completedTask, date: self.date)
                    self.tasks = self.itemManager.getTasksInCategoryForDate(self.selectedCategory, date: self.date)
                    self.pieChartTaskView.reloadData()
                    self.tableView.reloadData()
                    self.categories = self.itemManager.getCategoriesForDate(self.date)
                    return true
                }
                return [MGSwipeButton(title: "", icon: UIImage(named: "checkmark"), backgroundColor: greenColour, padding: pad, callback: callback)]
            }
        }
        else
        {
            if direction == MGSwipeDirection.LeftToRight
            {
                expansionSettings.fillOnTrigger = true
                expansionSettings.threshold = 1
                let pad:Int = 30
                let redColour = UIColor(red: 251/255, green: 73/255, blue: 71/255, alpha: 1.0)
                let callback:MGSwipeButtonCallback = {(sender: MGSwipeTableCell!) -> (Bool)  in
                    self.menu = CNPGridMenu(menuItems: [])
                    self.menu.delegate = self
                    self.presentGridMenu(self.menu, animated: true, completion: nil)
                    self.deletedTask = ((sender as! CustomCell).item)
                    let alert = DoAlertView()
                    alert.nAnimationType = 3
                    alert.dRound = 5
                    alert.bDestructive = false
                    alert.doYesNo("Deleting this category will delete all tasks associated with it. Do you want to continue?", yes: {(alertView) in
                        self.menu.dismissGridMenuAnimated(true, completion: nil)
                        self.itemManager.removeCategory(self.deletedTask as! Category)
                        self.categories = self.itemManager.getCategoriesForDate(self.date)
                        self.tableView.reloadData()
                        self.pieChartView.reloadData()
                        }, no: {(alertView) in
                            self.menu.dismissGridMenuAnimated(true, completion: nil)
                    })
                    return true
                }
                return [MGSwipeButton(title: "", icon: UIImage(named: "xmark"), backgroundColor: redColour, padding: pad, callback: callback)]
            }
        }
        return nil
    }
    
    //MARK selection and small switch animaiton
    func didSelectItem(index:Int)
    {
        if isTasks == false
        {
            self.isTasks = true
            self.selectedCategory = categories[index]
            self.tasks = self.itemManager.getTasksInCategoryForDate(self.selectedCategory, date: self.date)
            self.handleAnimationSwitch()
        }
        else
        {
            self.selectedIndex = index
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    func tappedSmallPieChart()
    {
        isTasks = false
        self.tasks = nil
        self.selectedCategory = nil
        self.categories = self.itemManager.getCategoriesForDate(self.date)
        self.handleAnimationSwitch()
    }
    
    func handleAnimationSwitch()
    {
        self.pieChartView.userInteractionEnabled = false
        if isTasks == true
        {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedSmallPieChart))
            recognizer.numberOfTapsRequired = 1
            let img = self.encapsulatingView.screenshot()
            imgView = UIImageView(frame: self.pieChartContainerView.frame)
            imgView.image = img
            imgView.contentMode = UIViewContentMode.ScaleAspectFill
            imgView.addGestureRecognizer(recognizer)
            imgView.userInteractionEnabled = true
            self.view.insertSubview(imgView, aboveSubview: self.pieChartView)
            self.encapsulatingView.removeFromSuperview()
            self.pieChartTaskView = XYPieChart(frame: CGRectMake(0, 0, self.pieChartTaskContainerView.frame.width, self.pieChartTaskContainerView.frame.height))
            self.createPieChartView(false, view: self.pieChartTaskView)
            self.pieChartTaskContainerView.addSubview(self.pieChartTaskView)
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 2, options: [], animations: {() in
                self.tableView.userInteractionEnabled = false
                self.imgView.frame = CGRectMake(53, self.pieChartContainerView.frame.minY+23, self.pieChartContainerView.frame.width*0.29, self.pieChartContainerView.frame.height*0.29)
                } , completion: {(success:Bool) in
                    self.tableView.userInteractionEnabled = true
                    self.pieChartView.userInteractionEnabled = true
            })
            self.pieChartTaskView.reloadData()
            self.selectedIndex = -1
            self.tableView.reloadDataAnimateWithWave(WaveAnimation.RightToLeftWaveAnimation)
        }
        else
        {
            self.selectedIndex = -1
            self.pieChartTaskView.removeFromSuperview()
            //self.pieChartTaskView = nil
            self.tableView.reloadDataAnimateWithWave(WaveAnimation.LeftToRightWaveAnimation)
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: [], animations: {() in
                self.tableView.userInteractionEnabled = false
                self.imgView.frame = CGRectMake(self.encapsulatingView.frame.minX, self.encapsulatingView.frame.minY, self.encapsulatingView.frame.width, self.encapsulatingView.frame.height)
                }, completion: {(completed:Bool) in
                    self.view.insertSubview(self.encapsulatingView, aboveSubview: self.pieChartTaskContainerView)
                    self.imgView.removeFromSuperview()
                    self.pieChartView.reloadData()
                    self.tableView.userInteractionEnabled = true
                    self.pieChartView.userInteractionEnabled = true
            })
        }
    }
    
    
    func doneButtonPressed() {
        if isTasks == true
        {
            if self.itemInputView.text != ""
            {
                if (self.hours == 0 && self.minutes != 0) || (self.hours != 0 && self.minutes == 0) || (self.hours != 0 && self.minutes != 0)
                {
                    //create or update task
                    if isNew == true
                    {
                        if let _ = self.fireDateForTask
                        {
                            if self.codeForTask != 1111111
                            {
                                itemManager.addNewTask(self.itemInputView.text, hours: self.hours, minutes: self.minutes, date: self.date, category: self.selectedCategory, hasReminder: true, repeatDays:self.codeForTask)
                                let localNotification:UILocalNotification = UILocalNotification()
                                localNotification.alertBody = self.itemInputView.text
                                localNotification.fireDate = self.fireDateForTask
                                localNotification.userInfo = ["uid":self.itemInputView.text]
                                localNotification.soundName = UILocalNotificationDefaultSoundName
                                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                            }
                            else
                            {
                                itemManager.addNewTask(self.itemInputView.text, hours: self.hours, minutes: self.minutes, date: self.date, category: self.selectedCategory, hasReminder: true, repeatDays:nil)
                                let localNotification:UILocalNotification = UILocalNotification()
                                localNotification.alertBody = self.itemInputView.text
                                localNotification.fireDate = self.fireDateForTask
                                localNotification.userInfo = ["uid":self.itemInputView.text]
                                localNotification.soundName = UILocalNotificationDefaultSoundName
                                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                            }
                        }
                        else
                        {
                            if self.codeForTask != 1111111
                            {
                                itemManager.addNewTask(self.itemInputView.text, hours: self.hours, minutes: self.minutes, date: self.date, category: self.selectedCategory, hasReminder: false, repeatDays:self.codeForTask)
                            }
                            else
                            {
                                itemManager.addNewTask(self.itemInputView.text, hours: self.hours, minutes: self.minutes, date: self.date, category: self.selectedCategory, hasReminder: false, repeatDays:nil)
                            }
                        }
                    }
                    else
                    {
                        self.itemManager.updateTask((self.oldItem as! Task), name: self.itemInputView.text, hours: self.hours, minutes: self.minutes)
                        if let _ = self.fireDateForTask
                        {
                            var didFindReminder:Bool = false
                            let app:UIApplication = UIApplication.sharedApplication()
                            for oneEvent in app.scheduledLocalNotifications! {
                                let notification = oneEvent as UILocalNotification
                                let userInfoCurrent = notification.userInfo! as! [String:AnyObject]
                                let uid = userInfoCurrent["uid"]! as! String
                                if uid == (self.oldItem as! Task).name! {
                                    app.cancelLocalNotification(notification)
                                    let localNotification:UILocalNotification = UILocalNotification()
                                    localNotification.alertBody = "\((self.oldItem as! Task).name!)"
                                    localNotification.fireDate = fireDateForTask
                                    localNotification.userInfo = ["uid":(self.oldItem as! Task).name!]
                                    localNotification.soundName = UILocalNotificationDefaultSoundName
                                    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                                    didFindReminder = true
                                    break;
                                }
                            }
                            if didFindReminder == false
                            {
                                let localNotification:UILocalNotification = UILocalNotification()
                                localNotification.alertBody = "\((self.oldItem as! Task).name!)"
                                localNotification.fireDate = self.fireDateForTask
                                localNotification.userInfo = ["uid":(self.oldItem as! Task).name!]
                                localNotification.soundName = UILocalNotificationDefaultSoundName
                                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                            }
                            (self.oldItem as! Task).hasReminder = true
                        }
                        else
                        {
                            let app:UIApplication = UIApplication.sharedApplication()
                            for oneEvent in app.scheduledLocalNotifications! {
                                let notification = oneEvent as UILocalNotification
                                let userInfoCurrent = notification.userInfo! as! [String:AnyObject]
                                let uid = userInfoCurrent["uid"]! as! String
                                if uid == (self.oldItem as! Task).name! {
                                    app.cancelLocalNotification(notification)
                                    break;
                                }
                            }
                        }
                    }
                    self.tasks = self.itemManager.getTasksInCategoryForDate(self.selectedCategory, date: self.date)
                    //self.tasks = self.itemManager.getTasksInCategory(self.selectedCategory)
                    self.pieChartTaskView.reloadData()
                    self.closeItemInput()
                    self.categories = self.itemManager.getCategoriesForDate(self.date)
                    self.tableView.reloadData()
                }
            }
        }
        else
        {
            if self.itemInputView.text != ""
            {
                //create or update category
                if isNew == true
                {
                    self.itemManager.addNewCategory(self.itemInputView.text)
                }
                else
                {
                    self.itemManager.updateCategory((self.oldItem as! Category), name: self.itemInputView.text)
                }
                self.closeItemInput()
                self.categories = self.itemManager.getCategoriesForDate(self.date)
                self.pieChartView.reloadData()
                self.tableView.reloadData()
            }
        }
    }
    
    func closeItemInput()
    {
        self.selectedIndex = -1
        if self.isTasks == true
        {
            self.pieChartTaskView.reloadData()
        }
        else
        {
            self.pieChartView.reloadData()
        }
        self.tableView.reloadData()
        self.tableView.userInteractionEnabled = true
        self.itemInputView.resignFirstResponder()
        self.itemInputView.alpha = 0
        self.centreDot.alpha = 0
        self.timeSelectionLabel.alpha = 0
        self.repeatButtonForInputView.alpha = 0
        self.reminderButtonForInputView.alpha = 0
        self.timeScrollView.alpha = 0
        UIView.animateWithDuration(0.3, animations: {() in
            self.tableView.alpha = 1
            self.encapsulatingView.alpha = 1
            self.imgView.alpha = 1
            self.pieChartTaskContainerView.alpha = 1
        })
    }
    
    func cancelButtonPressed() {
        self.closeItemInput()
    }
    
    
    @IBAction func dateButtonPressed(sender: AnyObject) {
        self.closeItemInput()
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("calendar") as! CalendarViewController
        vc.taskPageVC = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "settings"
        {
            self.closeItemInput()
            let vc = segue.destinationViewController as! SettingsViewController
            vc.delegate = self
            let darkeningView = UIView(frame: self.view.bounds)
            darkeningView.backgroundColor = UIColor.blackColor()
            darkeningView.alpha = 0
            self.view.addSubview(darkeningView)
            self.view.bringSubviewToFront(darkeningView)
            UIView.animateWithDuration(1, animations: {(darkeningView.alpha = 0.8)}, completion: {(success) in darkeningView.removeFromSuperview()})
        }
    }
    
    func willDismissViewController() {
        let darkeningView = UIView(frame: self.view.bounds)
        darkeningView.backgroundColor = UIColor.blackColor()
        darkeningView.alpha = 0.6
        self.view.addSubview(darkeningView)
        self.view.bringSubviewToFront(darkeningView)
        UIView.animateWithDuration(1, animations: {(darkeningView.alpha = 0)}, completion: {(success) in darkeningView.removeFromSuperview()})
    }
    
    
    var menu:CNPGridMenu!
    var presentingType:GridPresentationType!
    var isCreatingTask:Bool!
    func presentGridMenuView(type:GridPresentationType) {
        
        if type == GridPresentationType.reschedule
        {
            let item1 = CNPGridMenuItem()
            item1.icon = UIImage(named: "sun")
            item1.title = "Tomorrow"
            item1.retainsSelection = false
            
            let item2 = CNPGridMenuItem()
            item2.icon = UIImage(named: "two suns")
            item2.title = "In Two Days"
            item2.retainsSelection = false
            
            let item3 = CNPGridMenuItem()
            item3.icon = UIImage(named: "calendar orange")
            item3.title = "Next Week"
            item3.retainsSelection = false
            
            let item4 = CNPGridMenuItem()
            item4.icon = UIImage(named: "calendar orange")
            item4.title = "Friday"
            item4.retainsSelection = false
            
            let item5 = CNPGridMenuItem()
            item5.icon = UIImage(named: "calendar orange")
            item5.title = "Saturday"
            item5.retainsSelection = false
            
            let item6 = CNPGridMenuItem()
            item6.icon = UIImage(named: "calendar orange")
            item6.title = "Custom"
            item6.retainsSelection = false
            
            let gridStyle = CNPBlurEffectStyle(rawValue: 2)
            
            self.menu = CNPGridMenu(menuItems: [item1, item2, item3, item4, item5, item6])
            self.menu.delegate = self
            self.menu.blurEffectStyle = gridStyle!
            self.presentGridMenu(self.menu, animated: true, completion: nil)
            self.presentingType = .reschedule
        }
        else if type == GridPresentationType.reminder
        {
            self.menu = CNPGridMenu(menuItems: [])
            self.menu.delegate = self
            self.presentGridMenu(self.menu, animated: true, completion: nil)
            self.presentingType = .reminder
        }
        else if type == GridPresentationType.repeating
        {
            
            if isCreatingTask == false
            {
                
                let presentingTask = self.itemInputView.alpha == 0 ? self.tasks[self.selectedIndex] : (self.oldItem as! Task)
                var splitCode:[Int] = []
                var code = Int(presentingTask.repeatCode)
                while code > 0
                {
                    splitCode.append(code%10)
                    code = code/10
                }
                splitCode = splitCode.reverse()
                
                let item1 = CNPGridMenuItem()
                item1.icon = UIImage(named: "M")
                item1.title = "Monday"
                item1.isSelected = splitCode[1] == 2 ? true : false
                item1.retainsSelection = true
                
                let item2 = CNPGridMenuItem()
                item2.icon = UIImage(named: "T")
                item2.title = "Tuesday"
                item2.isSelected = splitCode[2] == 2 ? true : false
                item2.retainsSelection = true
                
                
                let item3 = CNPGridMenuItem()
                item3.icon = UIImage(named: "W")
                item3.title = "Wednesday"
                item3.isSelected = splitCode[3] == 2 ? true : false
                item3.retainsSelection = true
                
                let item4 = CNPGridMenuItem()
                item4.icon = UIImage(named: "Th")
                item4.title = "Thursday"
                item4.isSelected = splitCode[4] == 2 ? true : false
                item4.retainsSelection = true
                
                let item5 = CNPGridMenuItem()
                item5.icon = UIImage(named: "F")
                item5.title = "Friday"
                item5.isSelected = splitCode[5] == 2 ? true : false
                item5.retainsSelection = true
                
                let item6 = CNPGridMenuItem()
                item6.icon = UIImage(named: "S")
                item6.title = "Saturday"
                item6.isSelected = splitCode[6] == 2 ? true : false
                item6.retainsSelection = true
                
                let item7 = CNPGridMenuItem()
                item7.icon = UIImage(named: "S")
                item7.title = "Sunday"
                item7.isSelected = splitCode[0] == 2 ? true : false
                item7.retainsSelection = true
                
                self.menu = CNPGridMenu(menuItems: [item1, item2, item3, item4, item5, item6, item7])
                self.menu.delegate = self
                self.presentGridMenu(self.menu, animated: true, completion: nil)
                self.presentingType = .repeating
            }
            else
            {
                
                let item1 = CNPGridMenuItem()
                item1.icon = UIImage(named: "M")
                item1.title = "Monday"
                item1.isSelected = false
                item1.retainsSelection = true
                
                let item2 = CNPGridMenuItem()
                item2.icon = UIImage(named: "T")
                item2.title = "Tuesday"
                item2.isSelected = false
                item2.retainsSelection = true
                
                
                let item3 = CNPGridMenuItem()
                item3.icon = UIImage(named: "W")
                item3.title = "Wednesday"
                item3.isSelected = false
                item3.retainsSelection = true
                
                let item4 = CNPGridMenuItem()
                item4.icon = UIImage(named: "Th")
                item4.title = "Thursday"
                item4.isSelected =  false
                item4.retainsSelection = true
                
                let item5 = CNPGridMenuItem()
                item5.icon = UIImage(named: "F")
                item5.title = "Friday"
                item5.isSelected = false
                item5.retainsSelection = true
                
                let item6 = CNPGridMenuItem()
                item6.icon = UIImage(named: "S")
                item6.title = "Saturday"
                item6.isSelected = false
                item6.retainsSelection = true
                
                let item7 = CNPGridMenuItem()
                item7.icon = UIImage(named: "S")
                item7.title = "Sunday"
                item7.isSelected = false
                item7.retainsSelection = true
                
                self.menu = CNPGridMenu(menuItems: [item1, item2, item3, item4, item5, item6, item7])
                self.menu.delegate = self
                self.presentGridMenu(self.menu, animated: true, completion: nil)
                self.presentingType = .repeating
            }
            
        }
        
    }
    
    func gridMenuDidTapOnBackground(menu: CNPGridMenu!) {
        menu.dismissGridMenuAnimated(true, completion: nil)
        if self.presentingType == .repeating
        {
            if self.itemInputView.alpha == 1
            {
                self.itemInputView.becomeFirstResponder()
            }
            self.selectedIndex = -1
            self.pieChartTaskView.reloadData()
            self.tableView.reloadData()
        }
        self.presentingType = nil
    }
    
    func gridMenu(menu: CNPGridMenu!, didTapOnItem item: CNPGridMenuItem!) {
        
        if presentingType == .reschedule
        {
            
            let task = self.tasks[self.selectedIndex]
            var newDate:NSDate
            
            if item.title == "Tomorrow"
            {
                newDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: 1, toDate: self.date, options: [])!
                self.itemManager.updateDateForTask(task, date: newDate)
            }
            else if item.title == "In Two Days"
            {
                newDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: 2, toDate: self.date, options: [])!
                self.itemManager.updateDateForTask(task, date: newDate)
            }
            else if item.title == "Next Week"
            {
                newDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: 7, toDate: self.date, options: [])!
                self.itemManager.updateDateForTask(task, date: newDate)
            }
            else if item.title == "Friday"
            {
                for var x = 1; x <= 7; x += 1
                {
                    newDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: x, toDate: self.date, options: [])!
                    let comp = NSCalendar.currentCalendar().component(NSCalendarUnit.Weekday, fromDate: newDate)
                    if comp == 6
                    {
                        self.itemManager.updateDateForTask(task, date: newDate)
                        break
                    }
                }
            }
            else if item.title == "Saturday"
            {
                for var x = 1; x <= 7; x += 1
                {
                    newDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: x, toDate: self.date, options: [])!
                    let comp = NSCalendar.currentCalendar().component(NSCalendarUnit.Weekday, fromDate: newDate)
                    if comp == 7
                    {
                        self.itemManager.updateDateForTask(task, date: newDate)
                        break
                    }
                }
            }
            else if item.title == "Custom"
            {
                
            }
            else
            {
            }
            
            self.tasks = self.itemManager.getTasksInCategoryForDate(self.selectedCategory, date: self.date)
            self.categories = self.itemManager.getCategoriesForDate(self.date)
            self.tableView.reloadData()
            menu.dismissGridMenuAnimated(true, completion: nil)
            self.presentingType = nil
            self.pieChartTaskView.reloadData()
        }
        else if presentingType == .repeating
        {
            
            if isCreatingTask == false
            {
                let presentingTask = self.itemInputView.alpha == 0 ? self.tasks[self.selectedIndex] : (self.oldItem as! Task)
                var splitCode:[Int] = []
                var code = Int(presentingTask.repeatCode)
                while code > 0
                {
                    splitCode.append(code%10)
                    code = code/10
                }
                splitCode = splitCode.reverse()
                
                if item.title == "Monday"
                {
                    splitCode[1] = item.isSelected == true ? 2 : 1
                }
                else if item.title == "Tuesday"
                {
                    splitCode[2] = item.isSelected == true ? 2 : 1
                }
                else if item.title == "Wednesday"
                {
                    splitCode[3] = item.isSelected == true ? 2 : 1
                }
                else if item.title == "Thursday"
                {
                    splitCode[4] = item.isSelected == true ? 2 : 1
                }
                else if item.title == "Friday"
                {
                    splitCode[5] = item.isSelected == true ? 2 : 1
                }
                else if item.title == "Saturday"
                {
                    splitCode[6] = item.isSelected == true ? 2 : 1
                }
                else if item.title == "Sunday"
                {
                    splitCode[0] = item.isSelected == true ? 2 : 1
                }
                else
                {
                }
                
                var newCode = 0;
                for x in 0 ..< splitCode.count
                {
                    newCode += splitCode[x]*(Int(pow(Double(10), Double((6-x)))))
                }
                self.itemManager.setRepeatCodeForTask(presentingTask, code: newCode)
                if self.reminderButtonForInputView.alpha != 0
                {
                    if newCode != 1111111
                    {
                        self.repeatButtonForInputView.selected = true
                    }
                }
            }
            else
            {
                var splitCode:[Int] = []
                var code = self.codeForTask
                while code > 0
                {
                    splitCode.append(code%10)
                    code = code/10
                }
                splitCode = splitCode.reverse()
                
                if item.title == "Monday"
                {
                    splitCode[1] = item.isSelected == true ? 2 : 1
                }
                else if item.title == "Tuesday"
                {
                    splitCode[2] = item.isSelected == true ? 2 : 1
                }
                else if item.title == "Wednesday"
                {
                    splitCode[3] = item.isSelected == true ? 2 : 1
                }
                else if item.title == "Thursday"
                {
                    splitCode[4] = item.isSelected == true ? 2 : 1
                }
                else if item.title == "Friday"
                {
                    splitCode[5] = item.isSelected == true ? 2 : 1
                }
                else if item.title == "Saturday"
                {
                    splitCode[6] = item.isSelected == true ? 2 : 1
                }
                else if item.title == "Sunday"
                {
                    splitCode[0] = item.isSelected == true ? 2 : 1
                }
                else
                {
                }
                var newCode = 0;
                for x in 0 ..< splitCode.count
                {
                    newCode += splitCode[x]*(Int(pow(Double(10), Double((6-x)))))
                }
                self.codeForTask = newCode
                if newCode != 1111111
                {
                    self.repeatButtonForInputView.selected = true
                }
            }
        }
    }
    
    func dismissedAlertView() {
        self.menu.dismissGridMenuAnimated(true, completion: nil)
    }
    
    var fireDateForTask: NSDate!
    @IBAction func reminderButtonPressed(sender: UIButton) {
        self.itemInputView.resignFirstResponder()
        self.presentGridMenuView(.reminder)
        let alert = DoAlertView()
        alert.nAnimationType = 3
        alert.dRound = 5
        alert.bDestructive = false
        alert.nContentMode = 3
        alert.doYesNo("Set Reminder", body: "", yes: {(alertView) in
            self.fireDateForTask = alertView.datePicker.date
            self.reminderButtonForInputView.selected = true
            self.menu.dismissGridMenuAnimated(true, completion: nil)
            self.itemInputView.becomeFirstResponder()
            }, no: {(alertView) in
                self.dismissedAlertView()
                self.itemInputView.becomeFirstResponder()
                self.fireDateForTask = nil
                self.reminderButtonForInputView.selected = false
        })
    }
    
    var codeForTask:Int = 1111111
    @IBAction func repeatButtonPressed(sender: UIButton) {
        self.itemInputView.resignFirstResponder()
        self.isCreatingTask = self.isNew
        self.presentGridMenuView(.repeating)
    }
}

