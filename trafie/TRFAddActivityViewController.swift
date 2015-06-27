//
//  TRFAddActivityViewController.swift
//  trafie
//
//  Created by mathiou on 5/27/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit

class TRFAddActivityViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let emptyState = ["Nothing to select"]
    
    @IBOutlet weak var disciplineField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    var doneButton:UIButton = UIButton (frame: CGRectMake(100, 100, 100, 44))
    var disciplinesPickerView:UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.disciplinesPickerView.dataSource = self;
        self.disciplinesPickerView.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //  Main Discipline
    @IBAction func disciplineEditing(sender: UITextField) {
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.tag = 1
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.backgroundColor = UIColor.grayColor()
        
        sender.inputView = disciplinesPickerView
        
        sender.inputAccessoryView = doneButton
    }
    
    
    //  General functions
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case disciplinesPickerView:
            return disciplines.count;
        default:
            return 1;
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        switch pickerView {
        case disciplinesPickerView:
            disciplineField.text = disciplines[row]
            return disciplines[row]
        default:
            return emptyState[0];
        }
    }
    
    func doneButton(sender: UIButton) {
        switch sender.tag {
        case 1:
            disciplineField.resignFirstResponder()
        default:
            disciplineField.resignFirstResponder()
        }
    }

    
    @IBAction func dismissButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    @IBAction func saveActivityAndCloseView(sender: UIButton) {
        println("activity saved");
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    
    
    
    
}