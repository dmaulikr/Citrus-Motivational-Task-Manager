//
//  CalendarViewController.swift
//  Citrus
//
//  Created by Dilraj Devgun on 6/28/15.
//  Copyright (c) 2015 Clockwork Development, LLC. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, RSDFDatePickerViewDelegate, UIGestureRecognizerDelegate, BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource, SimpleBarChartDelegate, SimpleBarChartDataSource {

    @IBOutlet weak var verticalLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightFromCalendarConstraint: NSLayoutConstraint!
    @IBOutlet weak var smallStatsContainer: UIView!
    @IBOutlet weak var dailyGoalLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var multiplierLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var datePickerView: RSDFDatePickerView!
    var calendar:NSCalendar!
    var taskPageVC:ViewController!
    var rewardManager:RewardSystemManager = RewardSystemManager.sharedInstance
    var taprecognizer:UITapGestureRecognizer!
    var upswiperecognizer:UISwipeGestureRecognizer!
    var downswiperecognizer:UISwipeGestureRecognizer!
    var graph:BEMSimpleLineGraphView!
    var dataSet:[Day]!
    var statsTitleLabel:UILabel!
    var barGraph:SimpleBarChart!
    var label:UILabel!
    var label2:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statsTitleLabel = UILabel()
        statsTitleLabel.text = "Your Productivity"
        statsTitleLabel.textColor = UIColor.whiteColor()
        statsTitleLabel.font =  UIFont(name: "Bariol-Bold", size: 25)
        statsTitleLabel.sizeToFit()
        statsTitleLabel.alpha = 0
        
        
        self.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        self.calendar.locale = NSLocale.currentLocale()
        
        let streaks = rewardManager.getStreaks()
        var ranges:[GLCalendarDateRange] = []
        for streak in streaks
        {
            let range = GLCalendarDateRange(beginDate: streak.beginDate, endDate: streak.endDate)
            range.editable = false
            range.calendar = self.calendar
            if streak.isGoodStreak == 1
            {
                range.backgroundColor = UIColor(red: 126/255, green: 209/255, blue: 95/255, alpha: 1)
            }
            else
            {
                range.backgroundColor = UIColor(red: 252/255, green: 126/255, blue: 92/255, alpha: 1)
            }
            ranges.append(range)
        }
        
        let array = NSMutableArray(array: ranges)
        
        datePickerView.ranges = array

        self.datePickerView.pagingEnabled = true
        self.datePickerView.delegate = self
        self.datePickerView.reloadData()
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        
        self.pointsLabel.text = "\(self.rewardManager.getPoints())"
        if let _ = self.rewardManager.getLatestStreak()
        {
            if self.rewardManager.getLatestStreak()?.isGoodStreak == 1
            {
                self.streakLabel.text = "\(self.rewardManager.getDaysBetweenDates(self.rewardManager.getLatestStreak()!.beginDate, date2: self.rewardManager.getLatestStreak()!.endDate)+1)"
            }
            else
            {
                self.streakLabel.text = "0"
            }
        }
        else
        {
            self.streakLabel.text = "0"
        }
        self.multiplierLabel.text = "\(self.rewardManager.getMultiplier())x"
        self.dailyGoalLabel.text = "\(self.rewardManager.getGoal())"
        
        self.taprecognizer = UITapGestureRecognizer(target: self, action: #selector(CalendarViewController.tappedStatView(_:)))
        taprecognizer.numberOfTapsRequired = 1
        self.smallStatsContainer.addGestureRecognizer(self.taprecognizer)
        
        self.upswiperecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CalendarViewController.swipedStatViewUp(_:)))
        upswiperecognizer.direction = UISwipeGestureRecognizerDirection.Up
        self.smallStatsContainer.addGestureRecognizer(self.upswiperecognizer)
        
        self.downswiperecognizer = UISwipeGestureRecognizer(target: self, action: #selector(CalendarViewController.swipedStatViewDown(_:)))
        downswiperecognizer.direction = UISwipeGestureRecognizerDirection.Down
        self.smallStatsContainer.addGestureRecognizer(downswiperecognizer)
        
        self.dataSet = self.rewardManager.getDays()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        datePickerView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let streaks = rewardManager.getStreaks()
        var ranges:[GLCalendarDateRange] = []
        for streak in streaks
        {
            let range = GLCalendarDateRange(beginDate: streak.beginDate, endDate: streak.endDate)
            range.editable = false
            range.calendar = self.calendar
            if streak.isGoodStreak == 1
            {
                range.backgroundColor = UIColor(red: 126/255, green: 209/255, blue: 95/255, alpha: 1)
            }
            else
            {
                range.backgroundColor = UIColor(red: 252/255, green: 126/255, blue: 92/255, alpha: 1)
            }
            ranges.append(range)
        }
        
        let array = NSMutableArray(array: ranges)
        
        datePickerView.ranges = array
        datePickerView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.statsTitleLabel.frame = CGRectMake((self.view.frame.width/2)-(self.statsTitleLabel.frame.width/2), 15, self.statsTitleLabel.frame.width, self.statsTitleLabel.frame.height)
        self.smallStatsContainer.addSubview(self.statsTitleLabel)
    }
    
    func dateByAddingDays(days:Int, date:NSDate) -> NSDate
    {
        let comps = NSDateComponents()
        comps.day = days
        return calendar.dateByAddingComponents(comps, toDate: date, options: NSCalendarOptions())!
    }
    
    func datePickerView(view: RSDFDatePickerView!, shouldHighlightDate date: NSDate!) -> Bool {
        return true
    }
    
    func datePickerView(view: RSDFDatePickerView!, didSelectDate date: NSDate!) {
        //set date of delegate
        if let _ = taskPageVC
        {
            let components = self.calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: date)
            taskPageVC.date = self.calendar.dateFromComponents(components)
            taskPageVC.setTitleForDate()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func tappedStatView(sender:UITapGestureRecognizer)
    {
        if self.heightFromCalendarConstraint.constant == 0
        {
            self.createGraph()
            self.smallStatsContainer.layer.cornerRadius = 10
            self.view.bringSubviewToFront(self.smallStatsContainer)
            self.heightFromCalendarConstraint.constant = -(self.datePickerView.frame.height)
            self.verticalLabelConstraint.constant = (self.datePickerView.frame.height/2)*0.77
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 3, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() in
                self.view.layoutIfNeeded()
                self.statsTitleLabel.alpha = 1
                }, completion: {(success) in  })
        }
        else
        {
            self.smallStatsContainer.layer.cornerRadius = 0
            self.view.bringSubviewToFront(self.smallStatsContainer)
            self.heightFromCalendarConstraint.constant = 0
            self.verticalLabelConstraint.constant = 5
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 3, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() in
                self.view.layoutIfNeeded()
                self.statsTitleLabel.alpha = 0
                }, completion: {(success) in self.graph.removeFromSuperview() })
        }
    }
    
    func swipedStatViewUp(sender:UISwipeGestureRecognizer)
    {
        if self.heightFromCalendarConstraint.constant == 0
        {
            self.createGraph()
            self.smallStatsContainer.layer.cornerRadius = 10
            self.view.bringSubviewToFront(self.smallStatsContainer)
            self.heightFromCalendarConstraint.constant = -(self.datePickerView.frame.height)
            self.verticalLabelConstraint.constant = (self.datePickerView.frame.height/2)*0.77
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 3, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() in
                self.view.layoutIfNeeded()
                self.statsTitleLabel.alpha = 1
                }, completion: {(success) in })
        }
    }
    
    func swipedStatViewDown(sender:UISwipeGestureRecognizer)
    {
        if self.heightFromCalendarConstraint.constant != 0
        {
            self.smallStatsContainer.layer.cornerRadius = 0
            self.view.bringSubviewToFront(self.smallStatsContainer)
            self.heightFromCalendarConstraint.constant = 0
            self.verticalLabelConstraint.constant = 5
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 3, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {() in
                self.view.layoutIfNeeded()
                self.statsTitleLabel.alpha = 0
                }, completion: {(success) in self.graph.removeFromSuperview() })
        }
    }
    
    func createGraph()
    {
        self.graph = BEMSimpleLineGraphView(frame: CGRectMake(0,self.multiplierLabel.frame.maxY+100
            , self.smallStatsContainer.frame.width-10, self.datePickerView.frame.height*0.35))
        
        self.graph.delegate = self;
        self.graph.dataSource = self;
        self.smallStatsContainer.addSubview(self.graph)
        
        self.graph.enableTouchReport = true;
        self.graph.enablePopUpReport = true;
        self.graph.enableYAxisLabel = true;
        self.graph.autoScaleYAxis = true;
        self.graph.alwaysDisplayDots = true;
        self.graph.enableReferenceXAxisLines = false;
        self.graph.enableReferenceYAxisLines = false;
        self.graph.enableReferenceAxisFrame = true;
        self.graph.averageLine.enableAverageLine =  false;
        self.graph.animationGraphStyle = BEMLineAnimation.Draw;
        self.graph.widthLine = 2
        self.graph.colorTop = UIColor.clearColor();
        self.graph.colorBottom = UIColor.clearColor();
        self.graph.backgroundColor = UIColor.clearColor();
        
        
        label = UILabel()
        label.text = "Tasks Completed"
        label.font = UIFont(name: "Bariol-Regular", size: 18)
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        label.frame = CGRectMake((self.view.frame.width/2)-(label.frame.width/2), self.graph.frame.maxY+15, label.frame.width,label.frame.height)
        self.smallStatsContainer.addSubview(label)
        
        label2 = UILabel()
        label2.text = "Points"
        label2.font = UIFont(name: "Bariol-Regular", size: 18)
        label2.textColor = UIColor.whiteColor()
        label2.sizeToFit()
        label2.frame = CGRectMake((self.view.frame.width/2)-(label2.frame.width/2), self.multiplierLabel.frame.maxY+90, label2.frame.width,label2.frame.height)
        self.smallStatsContainer.addSubview(label2)
        
        
        self.barGraph = SimpleBarChart(frame: CGRectMake(10,
            (label.frame.maxY) + 15, self.smallStatsContainer.frame.width-15, self.datePickerView.frame.height*0.35))
        self.barGraph.dataSource = self
        self.barGraph.barShadowOffset = CGSizeZero
        self.barGraph.animationDuration = 0.6
        self.barGraph.barShadowColor = UIColor.clearColor()
        self.barGraph.barShadowAlpha = 0
        self.barGraph.barShadowRadius = 0
        self.barGraph.barWidth = 18
        self.barGraph.xLabelType = SimpleBarChartXLabelTypeVerticle
        
        var max = Int(self.dataSet[0].completed)
        for day in dataSet
        {
            if max < Int(day.completed)
            {
                max = Int(day.completed)
            }
        }
        
        if max < 10
        {
            self.barGraph.incrementValue = 1
        }
        else if max < 50
        {
            self.barGraph.incrementValue = 5
        }
        else if max < 100
        {
            self.barGraph.incrementValue = 10
        }
        else
        {
            self.barGraph.incrementValue = 15
        }
        self.barGraph.barTextType = SimpleBarChartBarTextTypeTop
        self.barGraph.barTextColor = UIColor.whiteColor()
        self.barGraph.gridColor = UIColor.clearColor()
        
        self.smallStatsContainer.addSubview(self.barGraph)
        self.barGraph.reloadData()
        
    }
    
    func numberOfPointsInGraph() -> Int32 {
        if self.dataSet.count == 1
        {
            return 0
        }
        return Int32(self.dataSet.count)
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        return CGFloat(self.dataSet[index].pointsForDay)
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: Int) -> String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd"
        
        var ending:String
        
        if formatter.stringFromDate(self.dataSet[index].date)  == "1"
        {
            ending = "st"
        }
        else if  formatter.stringFromDate(self.dataSet[index].date) == "2"
        {
            ending = "nd"
        }
        else if formatter.stringFromDate(self.dataSet[index].date) == "3"
        {
            ending = "rd"
        }
        else
        {
            ending = "th"
        }
        return formatter.stringFromDate(self.dataSet[index].date) + ending
    }
    
    func numberOfBarsInBarChart(barChart: SimpleBarChart!) -> UInt {
        return UInt(self.dataSet.count)
    }
    
    func barChart(barChart: SimpleBarChart!, valueForBarAtIndex index: UInt) -> CGFloat {
        return CGFloat(self.dataSet[Int(index)].completed)
    }
    
    func barChart(barChart: SimpleBarChart!, xLabelForBarAtIndex index: UInt) -> String! {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd"
        
        var ending:String
        
        if formatter.stringFromDate(self.dataSet[Int(index)].date)  == "1"
        {
            ending = "st"
        }
        else if  formatter.stringFromDate(self.dataSet[Int(index)].date) == "2"
        {
            ending = "nd"
        }
        else if formatter.stringFromDate(self.dataSet[Int(index)].date) == "3"
        {
            ending = "rd"
        }
        else
        {
            ending = "th"
        }
        return formatter.stringFromDate(self.dataSet[Int(index)].date) + ending
    }
    
    func barChart(barChart: SimpleBarChart!, colorForBarAtIndex index: UInt) -> UIColor! {
        return UIColor.whiteColor()
    }
    
    func barChart(barChart: SimpleBarChart!, textForBarAtIndex index: UInt) -> String! {
        return "\(dataSet[Int(index)].completed)"
    }
}
