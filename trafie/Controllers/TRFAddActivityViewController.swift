//
//  TRFAddActivityViewController.swift
//  trafie
//
//  Created by mathiou on 5/27/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
//import AKPickerView_Swift -- needed for horizontal picker

class TRFAddActivityViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {
    
    let EMPTY_STATE = "Please select discipline first"
    var selectedDiscipline: String = ""

    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var placeField: UITextField!
    @IBOutlet weak var competitionField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var notesField: UITextView!
    @IBOutlet weak var performancePickerView: UIPickerView!
    @IBOutlet weak var disciplinesPickerView: UIPickerView!
    
    var datePickerView:UIDatePicker = UIDatePicker()
    
    //pickers' attributes
    var doneButton: UIButton = UIButton (frame: CGRectMake(100, 100, 100, 35))
    var contentsOfPerformancePicker:[[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.disciplinesPickerView.dataSource = self;
        self.disciplinesPickerView.delegate = self;
        self.performancePickerView.dataSource = self;
        self.performancePickerView.delegate = self;
        
        self.disciplinesPickerView.selectRow(8, inComponent: 0, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //  Discipline
    @IBAction func disciplineEditing(sender: UITextField) {
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.tag = 1
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.backgroundColor = UIColor.grayColor()
        
        sender.inputView = disciplinesPickerView
        sender.inputAccessoryView = doneButton
    }
    
    // Performance
    
    @IBAction func performanceEditing(sender: UITextField) {
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.tag = 2
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.backgroundColor = UIColor.grayColor()
        
        sender.inputView = performancePickerView
        sender.inputAccessoryView = doneButton
    }
    

    
    
// GENERAL FUNCTIONS
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        switch pickerView {
        case disciplinesPickerView:
            return 1
        case performancePickerView:
            if contains(disciplinesTime, selectedDiscipline) {
                contentsOfPerformancePicker = [createIntRangeArray(0, 60), ["mins"], createIntRangeArray(0, 60), ["sec"], createIntRangeArray(0, 60), ["csec"]]
            } else if contains(disciplinesDistance, selectedDiscipline) {
                contentsOfPerformancePicker = [createIntRangeArray(0, 100), ["m"], createIntRangeArray(0, 100), ["cm"]]
            } else if contains( disciplinesPoints, selectedDiscipline){
                contentsOfPerformancePicker = [createIntRangeArray(0, 10), ["."], createIntRangeArray(0, 10), createIntRangeArray(0, 10), createIntRangeArray(0, 10), ["points"]]
            } else {
                contentsOfPerformancePicker = [[EMPTY_STATE]]
            }
            return contentsOfPerformancePicker.count
        default:
            return 0;
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case disciplinesPickerView:
            return disciplinesAll.count;
        case performancePickerView:
            return contentsOfPerformancePicker[component].count
        default:
            return 1;
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        switch pickerView {
        case disciplinesPickerView:
//            disciplineField.text = disciplinesAll[row]
            return disciplinesAll[row]
        case performancePickerView:
            return contentsOfPerformancePicker[component][row]
        default:
            return EMPTY_STATE
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var tempText = ""
        switch pickerView {
        case disciplinesPickerView:
            println(disciplinesAll[row])
            selectedDiscipline = disciplinesAll[row]
            performancePickerView.reloadAllComponents()
        case performancePickerView:
            if contains(disciplinesTime, selectedDiscipline) {
                tempText = contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)] + "" + contentsOfPerformancePicker[1][pickerView.selectedRowInComponent(1)] + "" + contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)] + "" + contentsOfPerformancePicker[3][pickerView.selectedRowInComponent(3)] + "" + contentsOfPerformancePicker[4][pickerView.selectedRowInComponent(4)]
            } else if contains(disciplinesDistance, selectedDiscipline) {
                tempText = contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)] + "" + contentsOfPerformancePicker[1][pickerView.selectedRowInComponent(1)] + "" + contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)] + "" + contentsOfPerformancePicker[3][pickerView.selectedRowInComponent(3)]
            } else if contains( disciplinesPoints, selectedDiscipline){
                tempText = contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)] + "" + contentsOfPerformancePicker[1][pickerView.selectedRowInComponent(1)] + "" + contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)] + "" + contentsOfPerformancePicker[3][pickerView.selectedRowInComponent(3)] + "" + contentsOfPerformancePicker[4][pickerView.selectedRowInComponent(4)] + "" + contentsOfPerformancePicker[5][pickerView.selectedRowInComponent(5)]
            } else {
                contentsOfPerformancePicker = [[EMPTY_STATE]]
            }
            println(tempText)
        default:
            println("else")
        }
    }
    
    
    func doneButton(sender: UIButton) {
        switch sender.tag {
        case 1: //discipline pickerView
            performancePickerView.reloadAllComponents()
        case 2: // Performance picker view
            println("performance pickerview");
        default:
            println("doneButton default");
        }
    }

    //  Birthday
    @IBAction func dateEditing(sender: UITextField) {
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        var dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        NSUserDefaults.standardUserDefaults().setObject(dateformatter.stringFromDate(sender.date), forKey: "birthday")
        dateField.text = dateformatter.stringFromDate(sender.date)
    }
    
    //page escape buttons
    @IBAction func dismissButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    @IBAction func saveActivityAndCloseView(sender: UIBarButtonItem) {
        println("activity saved");
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    
    
    
    
}