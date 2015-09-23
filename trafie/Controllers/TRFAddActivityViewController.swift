//
//  TRFAddActivityViewController.swift
//  trafie
//
//  Created by mathiou on 5/27/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import AKPickerView_Swift
import SwiftyJSON


// TODO: REFACTOR THIS CLASS. NEEDS TO HANDLE ADD + EDIT ACTIVITY!
class TRFAddActivityViewController: UITableViewController, AKPickerViewDataSource, AKPickerViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    // MARK: Outlets and Variables
    let EMPTY_STATE = "Please select discipline first"

    var selectedDiscipline: String = ""
    var selectedPerformance: String = ""

    var isFormValid: Bool = false
    
    let currentDate = NSDate()
    let dateFormatter = NSDateFormatter()

    @IBOutlet weak var dateField: UITextField!
    // TODO: CHANGE 'PLACE' TO 'RANK'. This and all occurencies
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

        var localUserMainDiscipline: String = ""
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
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .ShortStyle
        self.dateField.text = dateFormatter.stringFromDate(currentDate)
        self.datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        self.datePickerView.maximumDate = currentDate

        if isEditingActivity == true { // IN EDIT MODE : initialize the Input Fields
            let activity : TRFActivity = getActivityFromActivitiesArrayById(editingActivityID)
            self.akDisciplinesPickerView.selectItem(1, animated: true) // use function. The one with the TODO from below :)
            //self.performancePickerView.selectedRowInComponent(<#component: Int#>)
            self.competitionField.text = activity.getCompetition()
            self.locationField.text = activity.getLocation()
            self.placeField.text = activity.getPlace()
            self.notesField.text = activity.getNotes()
            
            // TODO: NEEDS TO BE FUNCTION
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let activityDate: String = activity.getDate()
            let dateShow : NSDate = dateFormatter.dateFromString(activityDate)!
            dateFormatter.dateFormat = "dd-MM-yyyy"
            self.dateField.text = dateFormatter.stringFromDate(dateShow)
            
            preSelectActivity(activity.getDiscipline())
            preSelectPerformance(Int(activity.getPerformance())!, discipline: activity.getDiscipline())
            
            watchFormValidity()
            
        } else { // IN ADD MODE : preselect by user main discipline
            preSelectActivity(localUserMainDiscipline)
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
        print("selected item: \(disciplinesAll[item])")
        selectedDiscipline = disciplinesAll[item]
        performancePickerView.reloadAllComponents()
    }

    // MARK: Vertical Picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        switch pickerView {
        case performancePickerView:
            if disciplinesTime.contains(selectedDiscipline) {
                contentsOfPerformancePicker = [createIntRangeArray(0, to: 60), [":"], createIntRangeArray(0, to: 60), ["."], createIntRangeArray(0, to: 60)]
            } else if disciplinesDistance.contains(selectedDiscipline) {
                contentsOfPerformancePicker = [createIntRangeArray(0, to: 100), ["."], createIntRangeArray(0, to: 100)]
            } else if disciplinesPoints.contains(selectedDiscipline){
                contentsOfPerformancePicker = [createIntRangeArray(0, to: 10), ["."], createIntRangeArray(0, to: 10), createIntRangeArray(0, to: 10), createIntRangeArray(0, to: 10)]
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
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
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
            if disciplinesTime.contains(selectedDiscipline) {
                tempText = "\(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])\(contentsOfPerformancePicker[1][pickerView.selectedRowInComponent(1)])\(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])\(contentsOfPerformancePicker[3][pickerView.selectedRowInComponent(3)])\(contentsOfPerformancePicker[4][pickerView.selectedRowInComponent(4)])"

                let hours : Int? = 0 * 60 * 60 * 100 // hours WILL BE ADDED in distances more than 5000m.
                let minutes : Int? = Int(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])! * 60 * 100
                let seconds : Int? = Int(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])! * 100
                let centiseconds : Int? = Int(contentsOfPerformancePicker[4][pickerView.selectedRowInComponent(4)])!
                
                let performance : Int = hours! + minutes! + seconds! + centiseconds!
                selectedPerformance = String(performance)
                
            } else if disciplinesDistance.contains(selectedDiscipline) {
                tempText = "\(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])\(contentsOfPerformancePicker[1][pickerView.selectedRowInComponent(1)])\(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])"
                
                let meters : Int? = Int(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])! * 10000
                let centimeters : Int? = Int(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])! * 100
                
                let performance : Int = meters! + centimeters!
                selectedPerformance = String(performance)
                
            } else if disciplinesPoints.contains(selectedDiscipline){
                tempText = "\(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])\(contentsOfPerformancePicker[1][pickerView.selectedRowInComponent(1)])\(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])\(contentsOfPerformancePicker[3][pickerView.selectedRowInComponent(3)])\(contentsOfPerformancePicker[4][pickerView.selectedRowInComponent(4)])"
                
                let thousand : Int? = Int(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])! * 1000
                let hundred : Int? = Int(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])! * 100
                let ten : Int? = Int(contentsOfPerformancePicker[3][pickerView.selectedRowInComponent(3)])! * 10
                let one : Int? = Int(contentsOfPerformancePicker[4][pickerView.selectedRowInComponent(4)])!
                
                let performance : Int = thousand! + hundred! + ten! + one!
                selectedPerformance = String(performance)
            } else {
                contentsOfPerformancePicker = [[EMPTY_STATE]] //USELESS
            }

            print("\(tempText) - \(selectedDiscipline)")
        default:
            print("else")
        }
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 86.0
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch pickerView {
        case performancePickerView:
            if disciplinesTime.contains(selectedDiscipline) || disciplinesDistance.contains(selectedDiscipline) {
                if component == 1 || component == 3 {
                    return 10
                } else {
                    return 70
                }
            } else if disciplinesPoints.contains(selectedDiscipline){
                if component == 1 {
                    return 10
                } else {
                    return 70
                }
            }
        default:
            return 70
        }
        return 70
    }
    
    // MARK: Form functions and Outlets
    @IBAction func competitionEditing(sender: UITextField) {
        watchFormValidity()
    }

    //Date
    @IBAction func dateEditing(sender: UITextField) {
        sender.inputView = datePickerView
        self.datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateformatter.timeStyle = NSDateFormatterStyle.LongStyle
        dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss" // WE WANT: "2015/09/02 15:45:28"
        dateField.text = dateformatter.stringFromDate(sender.date)
        watchFormValidity()
    }
    
    func watchFormValidity() {
        isFormValid = (!dateField.text!.isEmpty && competitionField.text?.characters.count > 6) ? true : false

        if(isFormValid) {
            saveActivityButton.tintColor = UIColor.blueColor()
        } else {
            saveActivityButton.tintColor = UIColor.grayColor()
        }
    }
    
    func preSelectActivity(activity: String) {
        for (index, _) in disciplinesAll.enumerate() {
            if disciplinesAll[index] == activity {
                self.akDisciplinesPickerView.selectItem(index, animated: true)
                return
            } else {
                self.akDisciplinesPickerView.selectItem(15, animated: true)
            }
        }
    }

    func preSelectPerformance(performance: Int, discipline: String) {
        //Initialize selectedPerformance
        selectedPerformance = String(performance)
        
        //Time
        if disciplinesTime.contains(discipline) {
            let centisecs = (performance % 100)
            let secs = ((performance) % 6000) / 100
            let mins = (performance % 360000) / 6000
            //let hours = (performance - secs - mins - centisecs) / 360000
            //hours
            /* for var i = 0; i < contentsOfPerformancePicker[0].count ; i++ {
                if contentsOfPerformancePicker[0][i].toInt() == hours {
                    self.performancePickerView.selectRow(i, inComponent: 0, animated: true)
                    break
                }
            } */
            //mins
            for var i = 0; i < contentsOfPerformancePicker[0].count ; i++ {
                if Int(contentsOfPerformancePicker[0][i]) == mins {
                    self.performancePickerView.selectRow(i, inComponent: 0, animated: true)
                    break
                }
            }
            //secs
            for var i = 0; i < contentsOfPerformancePicker[2].count ; i++ {
                if Int(contentsOfPerformancePicker[2][i]) == secs {
                    self.performancePickerView.selectRow(i, inComponent: 2, animated: true)
                    break
                }
            }
            //centisecs
            for var i = 0; i < contentsOfPerformancePicker[4].count ; i++ {
                if Int(contentsOfPerformancePicker[4][i]) == centisecs {
                    self.performancePickerView.selectRow(i, inComponent: 4, animated: true)
                    break
                }
            }
        // Distance
        }
        else if disciplinesDistance.contains(discipline) {
            let centimeters = (performance % 10000) / 100
            let meters = (performance - centimeters) / 10000
            for var i = 0; i < contentsOfPerformancePicker[0].count ; i++ {
                if Int(contentsOfPerformancePicker[0][i]) == meters {
                    self.performancePickerView.selectRow(i, inComponent: 0, animated: true)
                    break
                }
            }
            for var i = 0; i < contentsOfPerformancePicker[2].count ; i++ {
                if Int(contentsOfPerformancePicker[2][i]) == centimeters {
                    self.performancePickerView.selectRow(i, inComponent: 2, animated: true)
                    break
                }
            }

            // Points
        }
        else if disciplinesPoints.contains(discipline){
            let ones     = (performance % 10)
            let tens     = (performance % 100) / 10
            let hundreds = (performance % 1000) / 100
            let thousand = (performance - hundreds) / 1000
            //thousand
            for var i = 0; i < contentsOfPerformancePicker[0].count ; i++ {
                if Int(contentsOfPerformancePicker[0][i]) == thousand {
                    self.performancePickerView.selectRow(i, inComponent: 0, animated: true)
                    break
                }
            }
            //hundred
            for var i = 0; i < contentsOfPerformancePicker[2].count ; i++ {
                if Int(contentsOfPerformancePicker[2][i]) == hundreds {
                    self.performancePickerView.selectRow(i, inComponent: 2, animated: true)
                    break
                }
            }
            //tens
            for var i = 0; i < contentsOfPerformancePicker[3].count ; i++ {
                if Int(contentsOfPerformancePicker[3][i]) == tens {
                    self.performancePickerView.selectRow(i, inComponent: 3, animated: true)
                    break
                }
            }
            //ones
            for var i = 0; i < contentsOfPerformancePicker[4].count ; i++ {
                if Int(contentsOfPerformancePicker[4][i]) == ones {
                    self.performancePickerView.selectRow(i, inComponent: 4, animated: true)
                    break
                }
            }
        }
    }
    
    // MARK: Accesories + Page Buttons
    
    ///Dismisses the View
    @IBAction func dismissButton(sender: UIBarButtonItem) {
        // reset editable state
        isEditingActivity = false
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    ///Saves activity and dismisses View
    @IBAction func saveActivityAndCloseView(sender: UIBarButtonItem) {
        if sender === saveActivityButton && isFormValid {
            
//            let activity = ["discipline": selectedDiscipline,
//                            "performance": selectedPerformance,
//                            "date":dateField.text, // WE WANT: "2015/09/02 15:45:28"
//                            "place": placeField.text,
//                            "location": locationField.text,
//                            "competition": competitionField.text,
//                            "notes": notesField.text,
//                            "private": "false"]

//            switch isEditingActivity {
//            case false: // ADD MODE
//                TRFApiHandler.postActivity(testUserId, activityObject: activity)
//                    .responseJSON { (request, response, result) in
//                        print("request: \(request)")
//                        print("response: \(response)")
//                        print("result: \(result)")
//                        
////                        var responseJSONObject = JSON(JSONObject)
////                        var newActivity = TRFActivity(
////                            userId: responseJSONObject["_id"].stringValue,
////                            discipline: responseJSONObject["discipline"].stringValue,
////                            performance: responseJSONObject["performance"].stringValue,
////                            readablePerformance: convertPerformanceToReadable(responseJSONObject["performance"].stringValue, responseJSONObject["discipline"].stringValue),
////                            date: responseJSONObject["date"].stringValue,
////                            place: responseJSONObject["place"].stringValue,
////                            location: responseJSONObject["location"].stringValue,
////                            competition: responseJSONObject["competition"].stringValue,
////                            notes: responseJSONObject["notes"].stringValue,
////                            isPrivate: "false"
////                        )
//                        
////                        mutableActivitiesArray.addObject(newActivity)
//                        NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
//                        print("activity saved")
//                }
//            case true: // EDIT MODE
//                let oldActivity : TRFActivity = getActivityFromActivitiesArrayById(editingActivityID)
//                TRFApiHandler.updateActivityById(testUserId, activityId: oldActivity.getActivityId(), activityObject: activity)
//                    .responseJSON { (request, response, result) in
//                        print("request: \(request)")
//                        print("response: \(response)")
//                        print("JSONObject: \(result)")
//                        
////                        var responseJSONObject = JSON(JSONObject)
////                        var updatedActivity = TRFActivity(
////                            userId: responseJSONObject["_id"].stringValue,
////                            discipline: responseJSONObject["discipline"].stringValue,
////                            performance: responseJSONObject["performance"].stringValue,
////                            readablePerformance: convertPerformanceToReadable(responseJSONObject["performance"].stringValue, responseJSONObject["discipline"].stringValue),
////                            date: responseJSONObject["date"].stringValue,
////                            place: responseJSONObject["place"].stringValue,
////                            location: responseJSONObject["location"].stringValue,
////                            competition: responseJSONObject["competition"].stringValue,
////                            notes: responseJSONObject["notes"].stringValue,
////                            isPrivate: "false"
////                        )
//                        
////                        for var i = 0; i < mutableActivitiesArray.count; i++ {
////                            if (mutableActivitiesArray[i] as! TRFActivity).getActivityId() == oldActivity.getActivityId() {
////                                mutableActivitiesArray.replaceObjectAtIndex(i, withObject: updatedActivity)
////                            }
////                        }
//    
//                        NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
//                        print("activity saved")
//                }
//            default:
//                print("DEFAULT-state in isEditingActivity switch of saveActivityAndCloseView()")
//            }
            
        }
        else {
            print("There is something wrong with this form...")
        }

        // reset editable state
        isEditingActivity = false
        // dismiss view
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
}
