//
//  AddActivityViewController.swift
//  trafie
//
//  Created by mathiou on 5/27/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import AKPickerView_Swift
import SwiftyJSON

class AddActivityVC : UITableViewController, AKPickerViewDataSource, AKPickerViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    // MARK: Outlets and Variables
    var selectedDiscipline: String = ""
    var selectedPerformance: String = ""
    var timeFieldForDB : String = "" // variable that stores the value of time in format "HH:mm:ss" in order to be used in REST calls.

    let currentDate = NSDate()

    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var rankField: UITextField!
    @IBOutlet weak var competitionField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var notesField: UITextView!
    @IBOutlet weak var performancePickerView: UIPickerView!
    @IBOutlet var akDisciplinesPickerView: AKPickerView!
    @IBOutlet weak var saveActivityButton: UIBarButtonItem!
    @IBOutlet weak var dismissViewButton: UIBarButtonItem!
    @IBOutlet weak var savingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var isOutdoorSegment: UISegmentedControl!
    

    var datePickerView:UIDatePicker = UIDatePicker()
    var timePickerView:UIDatePicker = UIDatePicker()
    
    var savingIndicatorVisible : Bool = false
    var userId : String = ""
    
    //pickers' attributes
    var contentsOfPerformancePicker:[[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkStatusChanged:"), name: ReachabilityStatusChangedNotification, object: nil)
        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)

        var localUserMainDiscipline: String = ""
        localUserMainDiscipline = NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") as! String
        self.userId = (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)!

        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.title = "New Activity"
        
        //horizontal picker
        self.akDisciplinesPickerView.delegate = self
        self.akDisciplinesPickerView.dataSource = self
        self.akDisciplinesPickerView.font = UIFont.systemFontOfSize(20, weight: UIFontWeightLight)
        self.akDisciplinesPickerView.highlightedFont = UIFont.systemFontOfSize(20, weight: UIFontWeightRegular)
        self.akDisciplinesPickerView.interitemSpacing = 20.0
        self.akDisciplinesPickerView.highlightedTextColor = CLR_TRAFIE_RED
        self.akDisciplinesPickerView.pickerViewStyle = .Flat
        self.akDisciplinesPickerView.maskDisabled = true
        self.akDisciplinesPickerView.reloadData()
        
        //text fields
        self.competitionField.delegate = self
        self.locationField.delegate = self
        self.rankField.delegate = self
        self.rankField.keyboardType = UIKeyboardType.NumberPad

        // Performance picker
        self.performancePickerView.dataSource = self
        self.performancePickerView.delegate = self


        // Date initialization
        // WE WANT: "2015/09/02 15:45:28" combined
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.dateFormat = "yyyy/MM/dd" // "2015/09/02"
        timeFormatter.timeStyle = .LongStyle
        timeFormatter.dateFormat = "HH:mm:ss" // "15:45:28"
        self.datePickerView.datePickerMode = UIDatePickerMode.Date
        self.datePickerView.maximumDate = currentDate
        self.timePickerView.datePickerMode = UIDatePickerMode.Time
        
        // TableView 
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        tableView.tableFooterView = UIView(frame: CGRectZero)

        if isEditingActivity == true { // IN EDIT MODE : initialize the Input Fields
            self.navigationItem.title = "Edit Activity"

            let activity : Activity = getActivityFromActivitiesArrayById(editingActivityID)
            self.akDisciplinesPickerView.selectItem(1, animated: true) // use function. The one with the TODO from below :)
            //self.performancePickerView.selectedRowInComponent(<#component: Int#>)
            self.competitionField.text = activity.getCompetition()
            self.locationField.text = activity.getLocation()
            self.rankField.text = activity.getRank()
            self.notesField.text = activity.getNotes()
            self.isOutdoorSegment.selectedSegmentIndex = activity.getOutdoor() ? 0 : 1
            
            // TODO: NEEDS TO BE FUNCTION
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let activityDate: NSDate = activity.getDate()
            // TODO: remove?
            let dateShow : NSDate = activityDate
            dateFormatter.dateFormat = "yyyy/MM/dd"
            self.dateField.text = dateFormatter.stringFromDate(dateShow)
            
            self.datePickerView.setDate(activityDate, animated: true)
 
            // TODO: FIX TIME DIFFERENCE IN CONVERSION
            timeFormatter.dateFormat = "HH:mm:ss"
            self.timeFieldForDB = timeFormatter.stringFromDate(dateShow)
            timeFormatter.dateFormat = "HH:mm"
            self.timeField.text = timeFormatter.stringFromDate(dateShow)
            
            Utils.log("dateShow: \(dateShow) date:\(self.dateField.text) DBtime:\(self.timeFieldForDB) time:\(self.timeField.text)")
            
            preSelectDiscipline(activity.getDiscipline())
            preSelectPerformance(Int(activity.getPerformance())!, discipline: activity.getDiscipline())
            toggleSaveButton()

        } else { // IN ADD MODE : preselect by user main discipline
            preSelectDiscipline(localUserMainDiscipline)
            self.dateField.text = dateFormatter.stringFromDate(currentDate)
            timeFormatter.dateFormat = "HH:mm:ss"
            self.timeFieldForDB = timeFormatter.stringFromDate(currentDate)
            timeFormatter.dateFormat = "HH:mm"
            self.timeField.text = timeFormatter.stringFromDate(currentDate)
            self.isOutdoorSegment.selectedSegmentIndex = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Network Connection
    /// Handles notification event for network status changes
    func networkStatusChanged(notification: NSNotification) {
        Utils.log("networkStatusChanged to \(notification.userInfo)")
        Utils.initConnectionMsgInNavigationPrompt(self.navigationItem)
        toggleSaveButton()
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
        selectedDiscipline = disciplinesAll[item]
        performancePickerView.reloadAllComponents()
    }

    // MARK: Vertical Picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        switch pickerView {
        case performancePickerView:
            contentsOfPerformancePicker = Utils.getPerformanceLimitationsPerDiscipline(selectedDiscipline)
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
    
    // Attirbuted title for row
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        
        switch pickerView {
        case performancePickerView:
            let titleData = contentsOfPerformancePicker[component][row]
            let myTitle = NSAttributedString(string: titleData, attributes: [ NSFontAttributeName:UIFont.systemFontOfSize(45.0, weight: UIFontWeightLight ),NSForegroundColorAttributeName:UIColor.blackColor()])
            pickerLabel.attributedText = myTitle
        default:
            pickerLabel.attributedText = NSAttributedString(string: EMPTY_STATE, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(45.0, weight: UIFontWeightLight), NSForegroundColorAttributeName:UIColor.blackColor()])
        }
        
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var tempText = ""
        switch pickerView {
        case performancePickerView:
            if disciplinesTime.contains(selectedDiscipline) {
                tempText = "\(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])\(contentsOfPerformancePicker[1][pickerView.selectedRowInComponent(1)])\(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])\(contentsOfPerformancePicker[3][pickerView.selectedRowInComponent(3)])\(contentsOfPerformancePicker[4][pickerView.selectedRowInComponent(4)])"

                let hours : Int? = Int(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])! * 60 * 60 * 100 // hours WILL BE ADDED in distances more than 5000m.
                let minutes : Int? = Int(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])! * 60 * 100
                let seconds : Int? = Int(contentsOfPerformancePicker[4][pickerView.selectedRowInComponent(4)])! * 100
                let centiseconds : Int? = Int(contentsOfPerformancePicker[6][pickerView.selectedRowInComponent(6)])!
                
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

            Utils.log("\(tempText) - \(selectedDiscipline)")
        default:
            Utils.log("else")
        }
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 86.0
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch pickerView {
        case performancePickerView:
            if disciplinesTime.contains(selectedDiscipline) || disciplinesDistance.contains(selectedDiscipline) {
                if component == 1 || component == 3 || component == 5 { //separators
                    return 10
                } else {
                    return 60
                }
            } else if disciplinesPoints.contains(selectedDiscipline){
                if component == 1 {
                    return 10
                } else {
                    return 60
                }
            }
        default:
            return 60
        }
        return 60
    }
    
    // MARK: Form functions and Outlets
    /// Observes the editing of competition field and handles 'save' button accordingly.
    @IBAction func competitionEditing(sender: UITextField) {
        toggleSaveButton()
    }

    /// Observes date editing
    @IBAction func dateEditing(sender: UITextField) {
        sender.inputView = datePickerView
        self.datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    /// Observes date picker changes.
    func datePickerValueChanged(sender: UIDatePicker) {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateformatter.dateFormat = "yyyy/MM/dd" //"2015/09/02"
        self.dateField.text = dateformatter.stringFromDate(sender.date)
        isFormValid()
    }

    /// Observes time editing
    @IBAction func timeEditing(sender: UITextField) {
        sender.inputView = timePickerView
        self.timePickerView.addTarget(self, action: Selector("timePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }

    /// Observes time picker changes.
    func timePickerValueChanged(sender: UIDatePicker) {
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeStyle = NSDateFormatterStyle.LongStyle
        
        timeFormatter.dateFormat = "HH:mm:ss"
        self.timeFieldForDB = timeFormatter.stringFromDate(sender.date)
        timeFormatter.dateFormat = "HH:mm"
        self.timeField.text = timeFormatter.stringFromDate(sender.date)
    }
    
    /**
     Checks if required fields are completed correctly.
     - Returns: Boolean value for form validity.
     */
    func isFormValid() -> Bool{
        return (!self.dateField.text!.isEmpty && competitionField.text?.characters.count > 6)
    }

    /**
     Preselects the discipline in discipline-picker in case of editing

     - Parameter discipline: The discipline we want to be selected
     */
    func preSelectDiscipline(discipline: String) {
        for (index, _) in disciplinesAll.enumerate() {
            if disciplinesAll[index] == discipline {
                self.akDisciplinesPickerView.selectItem(index, animated: true)
                return
            } else {
                self.akDisciplinesPickerView.selectItem(15, animated: true)
            }
        }
    }

    /**
     Preselects the performance in performance-picker in case of editing
     
     - Parameter performance: The performance as an integer.
     - Parameter discipline: The discipline in which performance has been achieved.
     */
    func preSelectPerformance(performance: Int, discipline: String) {
        //Initialize selectedPerformance
        selectedPerformance = String(performance)
        
        //Time
        if disciplinesTime.contains(discipline) {
            let centisecs = (performance % 100)
            let secs = ((performance) % 6000) / 100
            let mins = (performance % 360000) / 6000
            let hours = (performance - secs - mins - centisecs) / 360000
            //hours
            for var i = 0; i < contentsOfPerformancePicker[0].count ; i++ {
                if Int(contentsOfPerformancePicker[0][i]) == hours {
                    self.performancePickerView.selectRow(i, inComponent: 0, animated: true)
                    break
                }
            }
            //mins
            for var i = 0; i < contentsOfPerformancePicker[2].count ; i++ {
                if Int(contentsOfPerformancePicker[2][i]) == mins {
                    self.performancePickerView.selectRow(i, inComponent: 2, animated: true)
                    break
                }
            }
            //secs
            for var i = 0; i < contentsOfPerformancePicker[4].count ; i++ {
                if Int(contentsOfPerformancePicker[4][i]) == secs {
                    self.performancePickerView.selectRow(i, inComponent: 4, animated: true)
                    break
                }
            }
            //centisecs
            for var i = 0; i < contentsOfPerformancePicker[6].count ; i++ {
                if Int(contentsOfPerformancePicker[6][i]) == centisecs {
                    self.performancePickerView.selectRow(i, inComponent: 6, animated: true)
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
    
    /// Dismisses the View
    @IBAction func dismissButton(sender: UIBarButtonItem) {
        // reset editable state
        isEditingActivity = false
        editingActivityID = ""
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    /// Checks form and toggles save button
    func toggleSaveButton() {
        let isValid = isFormValid()
        let status = Reach().connectionStatus()

        if(isValid && status.description != ReachabilityStatus.Unknown.description && status.description != ReachabilityStatus.Offline.description ) {
            saveActivityButton.tintColor = UIColor.blueColor()
            saveActivityButton.enabled = true
        } else {
            
            saveActivityButton.tintColor = CLR_MEDIUM_GRAY
            saveActivityButton.enabled = false
        }
    }
    
    /// Saves activity and dismisses View
    @IBAction func saveActivityAndCloseView(sender: UIBarButtonItem) {
        if sender === saveActivityButton {
            let timestamp : String = String(Utils.dateToTimestamp("\(self.dateField.text!)T\(String(self.timeFieldForDB))"))

            let activity = ["discipline": selectedDiscipline,
                            "performance": selectedPerformance,
                            "date": timestamp,
                            "rank": rankField.text,
                            "location": locationField.text,
                            "competition": competitionField.text,
                            "notes": notesField.text,
                            "isPrivate": "false",
                            "isOutdoor": "true"]

            savingIndicatorVisible = true
            tableView.reloadData()

            switch isEditingActivity {
            case false: // ADD MODE
                disableAllViewElements()
                ApiHandler.postActivity(self.userId, activityObject: activity)
                    .responseJSON { request, response, result in
                        switch result {
                        case .Success(let JSONResponse):
                            Utils.log("\(request)")
                            Utils.log("\(JSONResponse)")

                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

                            var responseJSONObject = JSON(JSONResponse)
                            let newActivity = Activity(
                                userId: responseJSONObject["userId"].stringValue,
                                activityId: responseJSONObject["_id"].stringValue,
                                discipline: responseJSONObject["discipline"].stringValue,
                                performance: responseJSONObject["performance"].stringValue,
                                readablePerformance: Utils.convertPerformanceToReadable(responseJSONObject["performance"].stringValue, discipline: responseJSONObject["discipline"].stringValue),
                                date: Utils.timestampToDate(responseJSONObject["date"].stringValue),
                                rank: responseJSONObject["rank"].stringValue,
                                location: responseJSONObject["location"].stringValue,
                                competition: responseJSONObject["competition"].stringValue,
                                notes: responseJSONObject["notes"].stringValue,
                                isPrivate: false,
                                isOutdoor: responseJSONObject["isOutdoor"].stringValue == "false" ? false : true
                            )

                            //add activity
                            //NOTE: dateFormatter.dateFormat MUST BE "yyyy-MM-dd'T'HH:mm:ss"
                            let yearOfActivity =  dateFormatter.stringFromDate(Utils.timestampToDate(responseJSONObject["date"].stringValue)).componentsSeparatedByString("-")[0]
                            addActivity(newActivity, section: yearOfActivity)
                            activitiesIdTable.append(newActivity.getActivityId())
                            
                            NSNotificationCenter.defaultCenter().postNotificationName("reloadActivities", object: nil)
                            
                            SweetAlert().showAlert("You rock!", subTitle: "Your activity has been saved!", style: AlertStyle.Success)
                            Utils.log("Activity Saved: \(newActivity)")
                            self.savingIndicator.stopAnimating()

                            self.dismissViewControllerAnimated(false, completion: {})
                            
                        case .Failure(let data, let error):
                            Utils.log("Request failed with error: \(error)")
                            if let data = data {
                                Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                            }
                        }

                }
            default: // EDIT MODE
                disableAllViewElements()
                let oldActivity : Activity = getActivityFromActivitiesArrayById(editingActivityID)
                ApiHandler.updateActivityById(userId, activityId: oldActivity.getActivityId(), activityObject: activity)
                    .responseJSON { request, response, result in
                        switch result {
                        case .Success(let JSONResponse):
                            Utils.log("Success")
                            Utils.log("\(JSONResponse)")

                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

                            var responseJSONObject = JSON(JSONResponse)
                            let updatedActivity = Activity(
                                userId: responseJSONObject["userId"].stringValue,
                                activityId: responseJSONObject["_id"].stringValue,
                                discipline: responseJSONObject["discipline"].stringValue,
                                performance: responseJSONObject["performance"].stringValue,
                                readablePerformance: Utils.convertPerformanceToReadable(responseJSONObject["performance"].stringValue, discipline: responseJSONObject["discipline"].stringValue),
                                date: Utils.timestampToDate(responseJSONObject["date"].stringValue),
                                rank: responseJSONObject["rank"].stringValue,
                                location: responseJSONObject["location"].stringValue,
                                competition: responseJSONObject["competition"].stringValue,
                                notes: responseJSONObject["notes"].stringValue,
                                isPrivate: false,
                                isOutdoor: responseJSONObject["isOutdoor"].stringValue == "false" ? false : true
                            )
                            
                            // remove old entry!
                            let oldKey = String(currentCalendar.components(.Year, fromDate: oldActivity.getDate()).year) //oldActivity.getDate().componentsSeparatedByString("-")[0]
                            removeActivity(oldActivity, section: oldKey)

                            //add activity
                            //NOTE: dateFormatter.dateFormat MUST BE "yyyy-MM-dd'T'HH:mm:ss"
                            let yearOfActivity = dateFormatter.stringFromDate(Utils.timestampToDate(responseJSONObject["date"].stringValue)).componentsSeparatedByString("-")[0]
                            addActivity(updatedActivity, section: yearOfActivity)

                            NSNotificationCenter.defaultCenter().postNotificationName("reloadActivities", object: nil)
                            NSNotificationCenter.defaultCenter().postNotificationName("reloadActivity", object: nil)
                            Utils.log("Activity Edited: \(updatedActivity)")
                            self.savingIndicator.stopAnimating()
                            SweetAlert().showAlert("Sweet!", subTitle: "That's right! \n Activity has been edited.", style: AlertStyle.Success)
                            
                            editingActivityID = ""
                            isEditingActivity = false
                            self.dismissViewControllerAnimated(false, completion: {})
                        case .Failure(let data, let error):
                            Utils.log("Request failed with error: \(error)")
                            if let data = data {
                                Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                            }
                        }
                        
                }
            }
            
        }
        else {
            Utils.log("There is something wrong with this form...")
        }
    }
    
    /// Called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    /// Disables all view elements. Used while loading.
    func disableAllViewElements() {
        self.dateField.enabled = false
        self.timeField.enabled = false
        self.rankField.enabled = false
        self.competitionField.enabled = false
        self.locationField.enabled = false
        self.notesField.editable = false
        self.performancePickerView.userInteractionEnabled = false
        self.akDisciplinesPickerView.userInteractionEnabled = false
        self.saveActivityButton.enabled = false
        self.dismissViewButton.enabled = false
    }
    
    
    // MARK: TableView Settings
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 { //section 1
            switch indexPath.row {
            case 0: //saving indicator
                savingIndicator.startAnimating()
                return savingIndicatorVisible == false ? 0.0 : 80.0
            case 1: //discipline
                return 73.0
            case 2: //performance
                return 120.0
            default: //
                return 44.0
            }
        } else if indexPath.section == 1 { //section 2
            return 44.0
        } else { //section 3
            return 136.0
        }
        
    }
    
}
