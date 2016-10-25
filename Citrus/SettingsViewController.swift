//
//  SettingsViewController.swift
//  Citrus
//
//  Created by Dilraj Devgun on 7/7/15.
//  Copyright (c) 2015 Clockwork Development, LLC. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate
{
    func willDismissViewController()
}

class SettingsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,SettingsTableViewCellDelegate, CNPGridMenuDelegate {

    @IBOutlet weak var settingsTableView: UITableView!
    
    @IBOutlet weak var settingNavBar: UINavigationBar!
    var delegate:SettingsViewControllerDelegate!
    var titles = ["Pie Chart Colors", "Set Goal", "Intro Video", "Notifications", "Feedback", "Follow Us"]
    var selectedIndex = -1
    var menu:CNPGridMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingNavBar.shadowImage = UIImage()
        settingNavBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()    }

    override func viewWillAppear(animated: Bool) {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        self.settingsTableView.tableFooterView = UIView(frame: CGRectZero)
        self.settingsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.settingsTableView.backgroundColor = UIColor(red: (253/255), green: (251/255), blue: (241/255), alpha: 1)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.settingsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dismissButtonPressed(sender: AnyObject) {
        if let d = self.delegate
        {
            d.willDismissViewController()
        }
        self.dismissViewControllerAnimated(true, completion: {(success) in
        })
    }
    
    func obtainCellType(indexPath:NSIndexPath) -> SettingsDetailViewType
    {
        let row = indexPath.row
        switch row
        {
            case 0: return SettingsDetailViewType.colorPicker
            case 1: return SettingsDetailViewType.scroller
            case 2: return SettingsDetailViewType.none
            case 3: return SettingsDetailViewType.slider
            case 4: return SettingsDetailViewType.none
            case 5: return SettingsDetailViewType.none
            case 6: return SettingsDetailViewType.none
            default: return SettingsDetailViewType.none
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell") as! SettingsTableViewCell
        cell.settingTitle.text = self.titles[indexPath.row]
        cell.setUpButtonText()
        cell.detailViewType = self.obtainCellType(indexPath)
        cell.setupDetailView()
        cell.cellDelegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if selectedIndex == indexPath.row
        {
            if (selectedIndex != 2) && (selectedIndex != 4) && (selectedIndex != 5)
            {
                return 190
            }
        }
        return 70
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedIndex == indexPath.row
        {
            selectedIndex = -1
        }
        else
        {
            self.selectedIndex = indexPath.row
        }
        if selectedIndex == 1
        {
            (self.settingsTableView.cellForRowAtIndexPath(indexPath) as! SettingsTableViewCell).setValueForScroller()
        }
        else if selectedIndex == 5
        {
            if UIApplication.sharedApplication().openURL(NSURL(string: "twitter://user?screen_name=@cwdapps")!) == true
            {
            }
            else
            {
                UIApplication.sharedApplication().openURL(NSURL(string:"https://twitter.com/cwdapps")!)
            }
        }
        self.settingsTableView.beginUpdates()
        self.settingsTableView.endUpdates()
    }
    
    func presentGridView() {
        self.menu = CNPGridMenu(menuItems: [])
        self.menu.delegate = self
        self.presentGridMenu(self.menu, animated: true, completion: nil)
        let alert = DoAlertView()
        alert.nAnimationType = 3
        alert.dRound = 5
        alert.bDestructive = false
        alert.nContentMode = 0
        alert.doYes("Alert", body: "To disable notifications please go to Settings -> Notifications -> Citrus -> Allow Notifications. Notifications can be turned on from within the app.", yes: {(alertView) in
            self.menu.dismissGridMenuAnimated(true, completion: nil)
        })
    }
    
    
}
