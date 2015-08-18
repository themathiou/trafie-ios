//
//  TRFAddActivityViewController.swift
//  trafie
//
//  Created by mathiou on 5/27/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import AKPickerView_Swift //-- needed for horizontal picker

class TRFAddActivityViewController: UITableViewController, AKPickerViewDataSource, AKPickerViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    // MARK: Outlets and Variables
    let EMPTY_STATE = "Please select discipline first"
    var selectedDiscipline: String = ""
    var localUserMainDiscipline: String = ""

    var isFormValid: Bool = false
    
    let currentDate = NSDate()
    let dateFormatter = NSDateFormatter()

    
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var placeField: UITextField!
    @IBOutlet weak var competitionField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var notesField: UITextView!
    @IBOutlet weak var performancePickerView: UIPickerView!
    @IBOutlet var akDisciplinesPickerView: AKPickerView!
    @IBOutlet weak var saveActivityButton: UIBarButtonItem!

    
    
    
    var datePickerView:UIDatePicker = UIDatePicker()
    
    //pickers' attributes
    var contentsOfPerformancePicker:[[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localUserMainDiscipline = NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") as! String

        self.automaticallyAdjustsScrollViewInsets = false
        
        //horizontal picker
        self.akDisciplinesPickerView.delegate = self
        self.akDisciplinesPickerView.dataSource = self
        self.akDisciplinesPickerView.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
        self.akDisciplinesPickerView.highlightedFont = UIFont(name: "HelveticaNeue", size: 20)!
        self.akDisciplinesPickerView.interitemSpacing = 20.0
        self.akDisciplinesPickerView.viewDepth = 1000.0
        self.akDisciplinesPickerView.pickerViewStyle = .Wheel
        self.akDisciplinesPickerView.maskDisabled = false
        self.akDisciplinesPickerView.reloadData()
        
        //text fields
        self.competitionField.delegate = self
        self.locationField.delegate = self
        self.placeField.delegate = self
        self.placeField.keyboardType = UIKeyboardType.NumberPad

        //performance picker
        self.performancePickerView.dataSource = self
        self.performancePickerView.delegate = self
        
        //Date initialization
        dateFormatter.dateStyle = .MediumStyle
        self.dateField.text = dateFormatter.stringFromDate(currentDate)
        self.datePickerView.datePickerMode = UIDatePickerMode.Date
        self.datePickerView.maximumDate = currentDate

        //preselect user discipline
        for (index, value) in enumerate(disciplinesAll) {
            if disciplinesAll[index] == localUserMainDiscipline {
                self.akDisciplinesPickerView.selectItem(index, animated: true)
                return
            } else {
                self.akDisciplinesPickerView.selectItem(15, animated: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Methods
    // MARK: Horizontal Picker
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return disciplinesAll.count
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        return NSLocalizedString(disciplinesAll[item], comment:"translation of discipline \(item)")
    }
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        println("selected item: \(disciplinesAll[item])")
        selectedDiscipline = disciplinesAll[item]
        performancePickerView.reloadAllComponents()
    }

    // MARK: Vertical Picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        switch pickerView {
        case performancePickerView:
            if contains(disciplinesTime, selectedDiscipline) {
                contentsOfPerformancePicker = [createIntRangeArray(0, 60), [":"], createIntRangeArray(0, 60), ["."], createIntRangeArray(0, 60)]
            } else if contains(disciplinesDistance, selectedDiscipline) {
                contentsOfPerformancePicker = [createIntRangeArray(0, 100), ["."], createIntRangeArray(0, 100)]
            } else if contains( disciplinesPoints, selectedDiscipline){
                contentsOfPerformancePicker = [createIntRangeArray(0, 10), ["."], createIntRangeArray(0, 10), createIntRangeArray(0, 10), createIntRangeArray(0, 10)]
            } else {
                contentsOfPerformancePicker = [[EMPTY_STATE]]
            }
            return contentsOfPerformancePicker.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case performancePickerView:
            return contentsOfPerformancePicker[component].count
        default:
            return 1
        }
    }
    
    //attirbuted title for row
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        
        let pickerLabel = UILabel()
        
        switch pickerView {
        case performancePickerView:
            let titleData = contentsOfPerformancePicker[component][row]
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 56.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
            pickerLabel.attributedText = myTitle
        default:
            pickerLabel.attributedText = NSAttributedString(string: EMPTY_STATE, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 56.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        }
        
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var tempText = ""
        switch pickerView {
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
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 86.0
    }
    
    @IBAction func competitionEditing(sender: UITextField) {
        watchFormValidity()
    }

    //Date
    @IBAction func dateEditing(sender: UITextField) {
        sender.inputView = datePickerView
        self.datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        var dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        NSUserDefaults.standardUserDefaults().setObject(dateformatter.stringFromDate(sender.date), forKey: "birthday")
        dateField.text = dateformatter.stringFromDate(sender.date)
        watchFormValidity()
    }
    
    func watchFormValidity() {
        isFormValid = (!dateField.text.isEmpty && count(competitionField.text) > 6) ? true : false

        if(isFormValid) {
            saveActivityButton.tintColor = UIColor.blueColor()
        } else {
            saveActivityButton.tintColor = UIColor.grayColor()
        }
    }
    
    // MARK: Accesories + Page Buttons
    
    ///Dismisses the View
    @IBAction func dismissButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    ///Saves activity and dismisses View
    @IBAction func saveActivityAndCloseView(sender: UIBarButtonItem) {
        if sender === saveActivityButton && isFormValid {
            self.dismissViewControllerAnimated(true, completion: {})
            println("activity saved")
        } else {
            println("There is something wrong with this form...")
        }
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
}