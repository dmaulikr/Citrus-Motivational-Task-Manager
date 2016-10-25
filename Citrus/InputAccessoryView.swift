//
//  InputAccessoryView.swift
//  test input view 2
//
//  Created by Dilraj Devgun on 6/22/15.
//  Copyright (c) 2015 Clockwork Development, LLC. All rights reserved.
//

import UIKit

protocol InputAccessoryViewDelegate
{
    func doneButtonPressed()
    func cancelButtonPressed()
}

class InputAccessoryView: UIView {

    @IBOutlet var view: UIView!
    var delegate: InputAccessoryViewDelegate!
    
    override init(frame:CGRect){
        super.init(frame: frame)
        NSBundle.mainBundle().loadNibNamed("inputAccessoryView", owner: self, options: nil)
        self.view.frame = frame
        self.bounds = self.view.bounds
        self.addSubview(self.view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSBundle.mainBundle().loadNibNamed("inputAccessoryView", owner: self, options: nil)
        self.bounds = self.view.bounds
        self.addSubview(self.view)
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        if self.delegate != nil
        {
            self.delegate.doneButtonPressed()
        }
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        if self.delegate != nil
        {
            self.delegate.cancelButtonPressed()
        }
    }
    
    
    
}
