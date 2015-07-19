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
    var selectedDiscipline: String = ""

    
    @IBOutlet weak var disciplineField: UITextField!
    @IBOutlet weak var performanceField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var placeField: UITextField!
    @IBOutlet weak var competitionField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var notesField: UITextField!
    
    //pickers' attributes
    var doneButton: UIButton = UIButton (frame: CGRectMake(100, 100, 100, 35))
    var disciplinesPickerView: UIPickerView = UIPickerView()
    var performancePickerView: UIPickerView = UIPickerView()
    var contentsOfPerformancePicker:[[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.disciplinesPickerView.dataSource = self;
        self.disciplinesPickerView.delegate = self;
        self.performancePickerView.dataSource = self;
        self.performancePickerView.delegate = self;
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
            if contains(disciplinesTime, disciplineField.text) {
                contentsOfPerformancePicker = [createIntRangeArray(0, 60), [":"], createIntRangeArray(0, 60), ["."], createIntRangeArray(0, 100)]
            } else if contains(disciplinesDistance, disciplineField.text) {
                contentsOfPerformancePicker = [createIntRangeArray(0, 100), ["."], createIntRangeArray(0, 100)]
            } else if contains( disciplinesPoints, disciplineField.text){
                contentsOfPerformancePicker = [createIntRangeArray(0, 10), ["."], createIntRangeArray(0, 10), createIntRangeArray(0, 10), createIntRangeArray(0, 10)]
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
            disciplineField.text = disciplinesAll[row]
            return disciplinesAll[row]
        case performancePickerView:
            return contentsOfPerformancePicker[component][row]
        default:
            return emptyState[0];
        }
    }
    
    func doneButton(sender: UIButton) {
        switch sender.tag {
        case 1: //discipline pickerView
            if contains(disciplinesTime, disciplineField.text) {
                selectedDiscipline = disciplineField.text;
            } else if contains(disciplinesDistance, disciplineField.text) {
                selectedDiscipline = disciplineField.text;
            } else if contains( disciplinesPoints, disciplineField.text){
                selectedDiscipline = disciplineField.text;
            } else {
                performanceField.text = "Please select a discipline first"
                println("please select a discipline first")
            }
            performancePickerView.reloadAllComponents()
            disciplineField.resignFirstResponder()
            
        case 2: // Performance picker view
            performanceField.resignFirstResponder()
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