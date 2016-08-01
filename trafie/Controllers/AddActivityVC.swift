//
//  AddActivityViewController.swift
//  trafie
//
//  Created by mathiou on 5/27/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import AKPickerView_Swift
import RealmSwift
import ALCameraViewController
import Alamofire

class AddActivityVC : UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    let NOTES_MAXIMUM_CHARS: Int = 1000

    // MARK: Outlets and Variables
    var selectedDiscipline: String = ""
    var selectedPerformance: String = "0"
    var timeFieldForDB: String = "" // variable that stores the value of time in format "HH:mm:ss" in order to be used in REST calls.
    var activityImageEdited: Bool = false
    let currentDate = NSDate()
    var activityImageToPost = UIImage()

    @IBOutlet weak var disciplinesField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var rankField: UITextField!
    @IBOutlet weak var competitionField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var notesField: UITextView!
    @IBOutlet weak var commentsField: UITextView!
    @IBOutlet weak var performancePickerView: UIPickerView!
    @IBOutlet weak var saveActivityButton: UIBarButtonItem!
    @IBOutlet weak var dismissViewButton: UIBarButtonItem!
    @IBOutlet weak var isOutdoorSegment: UISegmentedControl!
    @IBOutlet weak var isPrivateSegment: UISegmentedControl!
    @IBOutlet weak var activityImage: UIImageView!
    
    var disciplinesPickerView:UIPickerView = UIPickerView()
    var datePickerView:UIDatePicker = UIDatePicker()
    var timePickerView:UIDatePicker = UIDatePicker()
    var doneButton: UIButton = keyboardButtonCentered

    var userId : String = ""
    
    //pickers' attributes
    var contentsOfPerformancePicker:[[String]] = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let name = "iOS : Add Activity ViewController"
        Utils.googleViewHitWatcher(name);
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddActivityVC.showConnectionStatusChange(_:)), name: ReachabilityStatusChangedNotification, object: nil)

        var localUserMainDiscipline: String = ""
        localUserMainDiscipline = NSUserDefaults.standardUserDefaults().objectForKey("mainDiscipline") as! String
        self.userId = (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)!

        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.title = "New Activity"
        
        //horizontal picker
        self.disciplinesPickerView.delegate = self
        self.disciplinesPickerView.dataSource = self
        
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
        
        // Done button for keyboard and pickers
        doneButton.addTarget(self, action: #selector(AddActivityVC.doneButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.backgroundColor = CLR_MEDIUM_GRAY
        
        // use these values as default. It will change based on user preference.
        let selectedMeasurementUnit: String = (NSUserDefaults.standardUserDefaults().objectForKey("measurementUnitsDistance") as? String)!
        selectedDiscipline = "high_jump"
        contentsOfPerformancePicker = Utils.getPerformanceLimitationsPerDiscipline(selectedDiscipline, measurementUnit: selectedMeasurementUnit)
        disciplinesField.text = NSLocalizedString(selectedDiscipline, comment:"text shown in text field for main discipline")
        
        if isEditingActivity == true { // IN EDIT MODE : initialize the Input Fields
            self.navigationItem.title = "Edit Activity"

            let activity = uiRealm.objectForPrimaryKey(ActivityModelObject.self, key: editingActivityID)!
            self.disciplinesPickerView.selectRow(1, inComponent: 0, animated: true)
            self.competitionField.text = activity.competition
            self.locationField.text = activity.location
            self.rankField.text = activity.rank
            self.notesField.text = activity.notes
            self.commentsField.text = activity.comments
            self.isOutdoorSegment.selectedSegmentIndex = activity.isOutdoor ? 1 : 0
            self.isPrivateSegment.selectedSegmentIndex = activity.isPrivate ? 0 : 1
            if activity.imageUrl != nil && activity.imageUrl != "" {
                self.activityImage.kf_setImageWithURL(NSURL(string: activity.imageUrl!)!,
                  progressBlock: { receivedSize, totalSize in
                    print("\(receivedSize)/\(totalSize)")},
                  completionHandler: { image, error, cacheType, imageURL in
                    let screenSize: CGRect = UIScreen.mainScreen().bounds
                    let ratio: CGFloat = (screenSize.width - 16)/(image?.size.width)!
                    let _height = ratio*(image?.size.height)!
                    let _width = ratio*(image?.size.width)!
                    self.activityImage.image = Utils.ResizeImage(image!, targetSize: CGSizeMake(_height, _width))
                    self.activityImage.frame.size = CGSize(width: screenSize.width, height: _height)
                })
            }

            let dateShow : NSDate = activity.date
            dateFormatter.dateFormat = "yyyy/MM/dd"
            self.dateField.text = dateFormatter.stringFromDate(dateShow)
            
            self.datePickerView.setDate(activity.date, animated: true)
 
            timeFormatter.dateFormat = "HH:mm:ss"
            self.timeFieldForDB = timeFormatter.stringFromDate(dateShow)
            timeFormatter.dateFormat = "HH:mm"
            self.timeField.text = timeFormatter.stringFromDate(dateShow)
            
            Utils.log("dateShow: \(dateShow) date:\(self.dateField.text) DBtime:\(self.timeFieldForDB) time:\(self.timeField.text)")
            
            preSelectDiscipline(activity.discipline!)
            selectedDiscipline = activity.discipline!
            self.disciplinesField.text = NSLocalizedString(selectedDiscipline, comment:"text shown in text field for main discipline")
            self.contentsOfPerformancePicker = Utils.getPerformanceLimitationsPerDiscipline(selectedDiscipline, measurementUnit: selectedMeasurementUnit)
            let selectedMeasurementUnit: String = (NSUserDefaults.standardUserDefaults().objectForKey("measurementUnitsDistance") as? String)!
            preSelectPerformance(Int(activity.performance!)!, discipline: activity.discipline!, measurementUnit: selectedMeasurementUnit)

        } else { // IN ADD MODE : preselect by user main discipline
            preSelectDiscipline(localUserMainDiscipline)
            preSetPerformanceToZero(localUserMainDiscipline)
            self.dateField.text = dateFormatter.stringFromDate(currentDate)
            timeFormatter.dateFormat = "HH:mm:ss"
            self.timeFieldForDB = timeFormatter.stringFromDate(currentDate)
            timeFormatter.dateFormat = "HH:mm"
            self.timeField.text = timeFormatter.stringFromDate(currentDate)
            self.isOutdoorSegment.selectedSegmentIndex = 1
            self.isPrivateSegment.selectedSegmentIndex = 1
        }
        
        toggleSaveButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Network Connection
    @objc func showConnectionStatusChange(notification: NSNotification) {
        Utils.showConnectionStatusChange()
    }
    
    // MARK:- Methods
    // MARK: Vertical Pickers
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        switch pickerView {
        case performancePickerView:
            let selectedMeasurementUnit: String = (NSUserDefaults.standardUserDefaults().objectForKey("measurementUnitsDistance") as? String)!
            contentsOfPerformancePicker = Utils.getPerformanceLimitationsPerDiscipline(selectedDiscipline, measurementUnit: selectedMeasurementUnit)
            return contentsOfPerformancePicker.count
        case disciplinesPickerView:
            return 1
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case performancePickerView:
            return contentsOfPerformancePicker[component].count
        case disciplinesPickerView:
            return disciplinesAll.count;
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
            let myTitle = NSAttributedString(string: titleData, attributes: [ NSFontAttributeName:UIFont.systemFontOfSize(45.0, weight: UIFontWeightUltraLight ),NSForegroundColorAttributeName:UIColor.blackColor()])
            pickerLabel.attributedText = myTitle
        case disciplinesPickerView:
            let titleData = NSLocalizedString(disciplinesAll[row], comment:"text shown in text field for main discipline")
            let myTitle = NSAttributedString(string: titleData, attributes: [ NSFontAttributeName:UIFont.systemFontOfSize(20.0, weight: UIFontWeightLight),NSForegroundColorAttributeName:UIColor.blackColor()])
            pickerLabel.attributedText = myTitle
        default:
            pickerLabel.attributedText = NSAttributedString(string: EMPTY_STATE, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(20.0, weight: UIFontWeightLight), NSForegroundColorAttributeName:UIColor.blackColor()])
        }
        
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var tempText = ""
        switch pickerView {
        case disciplinesPickerView:
            disciplinesField.text = NSLocalizedString(disciplinesAll[row], comment:"text shown in text field for main discipline")
            selectedDiscipline = disciplinesAll[row]
            performancePickerView.reloadAllComponents()
            preSetPerformanceToZero(selectedDiscipline)
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
                let selectedMeasurementUnit: String = (NSUserDefaults.standardUserDefaults().objectForKey("measurementUnitsDistance") as? String)!
                switch(selectedMeasurementUnit) {
                case MeasurementUnits.Feet.rawValue:
                    tempText = "\(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])' \(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])\(contentsOfPerformancePicker[3][pickerView.selectedRowInComponent(3)]) \""
                    
                    
                    let feet : Int = Int(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])! * 30480
                    let inches : Double = (Utils.convertFractionToPercentage(contentsOfPerformancePicker[3][pickerView.selectedRowInComponent(3)]) + Double(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])!) * 2540
                    
                    let performance : Double = Double(feet) + inches
                    selectedPerformance = String(performance)

                default: //meters
                    tempText = "\(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])\(contentsOfPerformancePicker[1][pickerView.selectedRowInComponent(1)])\(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])"
                    
                    let meters : Int? = Int(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])! * 100000
                    let centimeters : Int? = Int(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])! * 1000
                    
                    let performance : Int = meters! + centimeters!
                    selectedPerformance = String(performance)
                }
            } else if disciplinesPoints.contains(selectedDiscipline){
                tempText = "\(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])\(contentsOfPerformancePicker[1][pickerView.selectedRowInComponent(1)])\(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])\(contentsOfPerformancePicker[3][pickerView.selectedRowInComponent(3)])\(contentsOfPerformancePicker[4][pickerView.selectedRowInComponent(4)])"
                
                let thousand : Int? = Int(contentsOfPerformancePicker[0][pickerView.selectedRowInComponent(0)])! * 1000
                let hundred : Int? = Int(contentsOfPerformancePicker[2][pickerView.selectedRowInComponent(2)])! * 100
                let ten : Int? = Int(contentsOfPerformancePicker[3][pickerView.selectedRowInComponent(3)])! * 10
                let one : Int? = Int(contentsOfPerformancePicker[4][pickerView.selectedRowInComponent(4)])!
                
                let performance : Int = thousand! + hundred! + ten! + one!
                selectedPerformance = String(performance)
            } else {
                contentsOfPerformancePicker = [[EMPTY_STATE]]
            }

            Utils.log("\(tempText) - \(selectedDiscipline)")
        default:
            Utils.log("else")
        }
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        switch pickerView {
        case performancePickerView:
            return 70.0
        default:
            return 40.0
        }
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch pickerView {
        case performancePickerView:
            if disciplinesTime.contains(selectedDiscipline) {
                if component == 1 || component == 3 || component == 5 { //separators
                    return 10
                } else {
                    return 60
                }
            } else if disciplinesDistance.contains(selectedDiscipline) {
                switch (component) {
                case 0:
                    return 80
                case 1:
                    return 10
                case 3:
                    return 40
                case 4:
                    return 30
                default:
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
            return 500
        }
        return 60
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case disciplinesPickerView:
            return NSLocalizedString(disciplinesAll[row], comment:"translation of discipline \(row)")
        default:
            return "undefined value";
        }
    }
    
    // MARK: Form functions and Outlets
    
    @IBAction func disciplineEditing(sender: UITextField) {
        sender.inputView = disciplinesPickerView
        doneButton.tag = 6
        sender.inputAccessoryView = doneButton
    }
    
    /// Observes the editing of competition field and handles 'save' button accordingly.
    @IBAction func competitionEditing(sender: UITextField) {
        toggleSaveButton()
    }

    @IBAction func competitionEditingStarted(sender: UITextField) {
        doneButton.tag = 1
        sender.inputAccessoryView = doneButton
    }
    
    /// Observes date editing
    @IBAction func dateEditing(sender: UITextField) {
        doneButton.tag = 2
        sender.inputAccessoryView = doneButton
        sender.inputView = datePickerView
        self.datePickerView.addTarget(self, action: #selector(AddActivityVC.datePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        toggleSaveButton()
    }
    
    /// Observes date picker changes.
    func datePickerValueChanged(sender: UIDatePicker) {
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.dateFormat = "yyyy/MM/dd" //"2015/09/02"
        self.dateField.text = dateFormatter.stringFromDate(sender.date)
        isFormValid()
    }

    /// Observes time editing
    @IBAction func timeEditing(sender: UITextField) {
        doneButton.tag = 3
        sender.inputAccessoryView = doneButton
        sender.inputView = timePickerView
        self.timePickerView.addTarget(self, action: #selector(AddActivityVC.timePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }

    /// Observes time picker changes.
    func timePickerValueChanged(sender: UIDatePicker) {
        timeFormatter.timeStyle = NSDateFormatterStyle.LongStyle
        timeFormatter.dateFormat = "HH:mm:ss"
        self.timeFieldForDB = timeFormatter.stringFromDate(sender.date)
        timeFormatter.dateFormat = "HH:mm"
        self.timeField.text = timeFormatter.stringFromDate(sender.date)
    }
    
    // Observes location editing
    @IBAction func locationEditing(sender: UITextField) {
        doneButton.tag = 4
        sender.inputAccessoryView = doneButton
    }
    
    // Observes rank editing
    @IBAction func rankEditing(sender: UITextField) {
        doneButton.tag = 5
        sender.inputAccessoryView = doneButton
    }
    
    /**
     Checks if required fields are completed correctly.
     - Returns: Boolean value for form validity.
     */
    func isFormValid() -> Bool{
        let requiredAreOk: Bool = (!self.dateField.text!.isEmpty && competitionField.text?.characters.count > 2)
        let commentsLengthValid: Bool = self.commentsField.text?.characters.count < NOTES_MAXIMUM_CHARS
        let notesLengthValid: Bool = self.commentsField.text?.characters.count < NOTES_MAXIMUM_CHARS
        return requiredAreOk && commentsLengthValid && notesLengthValid
    }

    /**
     Preselects the discipline in discipline-picker in case of editing

     - Parameter discipline: The discipline we want to be selected
     */
    func preSelectDiscipline(discipline: String) {
        for (index, _) in disciplinesAll.enumerate() {
            if disciplinesAll[index] == discipline {
                self.disciplinesPickerView.selectRow(index, inComponent:0, animated: true)
                return
            } else {
                self.disciplinesPickerView.selectRow(10, inComponent:0, animated: true)
            }
        }
    }

    /**
     Preselects the performance in performance-picker in case of editing
     
     - Parameter performance: The performance as an integer.
     - Parameter discipline: The discipline in which performance has been achieved.
     - Parameter measurementUnit: String that should match MeasurementUnits.
     */
    func preSelectPerformance(performance: Int, discipline: String, measurementUnit: String) {
        //Initialize selectedPerformance
        selectedPerformance = String(performance)

        //Time
        if disciplinesTime.contains(discipline) {
            let centisecs = (performance % 100)
            let secs = ((performance) % 6000) / 100
            let mins = (performance % 360000) / 6000
            let hours = (performance - secs - mins - centisecs) / 360000
            // On every column there will be 3 matched occurencies. We will use the second one in order to emulate circular behaviour
            //hours
            for i in 0 ..< contentsOfPerformancePicker[0].count  {
                if Int(contentsOfPerformancePicker[0][i]) == hours {
                    self.performancePickerView.selectRow(i + (contentsOfPerformancePicker[0].count/3), inComponent: 0, animated: true)
                    break
                }
            }
            //mins
            for i in 0 ..< contentsOfPerformancePicker[2].count  {
                if Int(contentsOfPerformancePicker[2][i]) == mins {
                    self.performancePickerView.selectRow(i + (contentsOfPerformancePicker[2].count/3), inComponent: 2, animated: true)
                    break
                }
            }
            //secs
            for i in 0 ..< contentsOfPerformancePicker[4].count  {
                if Int(contentsOfPerformancePicker[4][i]) == secs {
                    self.performancePickerView.selectRow(i + (contentsOfPerformancePicker[4].count/3), inComponent: 4, animated: true)
                    break
                }
            }
            //centisecs
            for i in 0 ..< contentsOfPerformancePicker[6].count  {
                if Int(contentsOfPerformancePicker[6][i]) == centisecs {
                    self.performancePickerView.selectRow(i + (contentsOfPerformancePicker[6].count/3), inComponent: 6, animated: true)
                    break
                }
            }
        } // Distance
        else if disciplinesDistance.contains(discipline) {
            if measurementUnit == MeasurementUnits.Feet.rawValue {
                
                var inches = Double(performance) * 0.0003937007874
                let feet = floor(inches / 12)
                inches = inches - 12 * feet
                var inchesInteger = floor(inches)
                var inchesDecimal = inches - inchesInteger
                
                if(inchesDecimal >= 0.125 && inchesDecimal < 0.375) {
                    inchesDecimal = 0.25
                }
                else if(inchesDecimal >= 0.375 && inchesDecimal < 0.625) {
                    inchesDecimal = 0.5
                }
                else if(inchesDecimal >= 0.625 && inchesDecimal < 0.875) {
                    inchesDecimal = 0.75
                }
                else if(inchesDecimal >= 0.875) {
                    inchesInteger += 1
                    inchesDecimal = 0
                }
                else {
                    inchesDecimal = 0
                }
                
                for i in 0 ..< contentsOfPerformancePicker[0].count  {
                    if Int(contentsOfPerformancePicker[0][i]) == Int(feet) {
                        self.performancePickerView.selectRow(i + (contentsOfPerformancePicker[0].count/3), inComponent: 0, animated: true)
                        break
                    }
                }
                for i in 0 ..< contentsOfPerformancePicker[2].count  {
                    if Int(contentsOfPerformancePicker[2][i]) == Int(inchesInteger) {
                        self.performancePickerView.selectRow(i + (contentsOfPerformancePicker[2].count/3), inComponent: 2, animated: true)
                        break
                    }
                }
                for i in 0 ..< contentsOfPerformancePicker[3].count  {
                    if contentsOfPerformancePicker[3][i] == Utils.convertPercentageToFraction(inchesDecimal) {
                        self.performancePickerView.selectRow(i + (contentsOfPerformancePicker[3].count/3), inComponent: 3, animated: true)
                        break
                    }
                }
            }
            else { //meters
                let centimeters = (performance % 100000) / 1000
                let meters = (performance - centimeters) / 100000
                for i in 0 ..< contentsOfPerformancePicker[0].count  {
                    if Int(contentsOfPerformancePicker[0][i]) == meters {
                        self.performancePickerView.selectRow(i + (contentsOfPerformancePicker[0].count/3), inComponent: 0, animated: true)
                        break
                    }
                }
                for i in 0 ..< contentsOfPerformancePicker[2].count  {
                    if Int(contentsOfPerformancePicker[2][i]) == centimeters {
                        self.performancePickerView.selectRow(i + (contentsOfPerformancePicker[2].count/3), inComponent: 2, animated: true)
                        break
                    }
                }
            }

        } // Points
        else if disciplinesPoints.contains(discipline){
            let ones     = (performance % 10)
            let tens     = (performance % 100) / 10
            let hundreds = (performance % 1000) / 100
            let thousand = (performance - hundreds) / 1000
            //thousand
            for i in 0 ..< contentsOfPerformancePicker[0].count  {
                if Int(contentsOfPerformancePicker[0][i]) == thousand {
                    self.performancePickerView.selectRow(i + (contentsOfPerformancePicker[0].count/3), inComponent: 0, animated: true)
                    break
                }
            }
            //hundred
            for i in 0 ..< contentsOfPerformancePicker[2].count  {
                if Int(contentsOfPerformancePicker[2][i]) == hundreds {
                    self.performancePickerView.selectRow(i + (contentsOfPerformancePicker[2].count/3), inComponent: 2, animated: true)
                    break
                }
            }
            //tens
            for i in 0 ..< contentsOfPerformancePicker[3].count  {
                if Int(contentsOfPerformancePicker[3][i]) == tens {
                    self.performancePickerView.selectRow(i + (contentsOfPerformancePicker[3].count/3), inComponent: 3, animated: true)
                    break
                }
            }
            //ones
            for i in 0 ..< contentsOfPerformancePicker[4].count  {
                if Int(contentsOfPerformancePicker[4][i]) == ones {
                    self.performancePickerView.selectRow(i + (contentsOfPerformancePicker[4].count/3), inComponent: 4, animated: true)
                    break
                }
            }
        }
    }

    /**
     Preselects the performance in performance-picker to zeros. It's necessary when initialize picker and we want it to be circular.
     */
    func preSetPerformanceToZero(discipline: String) {
        //Time
        if disciplinesTime.contains(discipline) {
            //hours
            self.performancePickerView.selectRow(contentsOfPerformancePicker[0].count / 3, inComponent: 0, animated: true)
            //mins
            self.performancePickerView.selectRow(contentsOfPerformancePicker[2].count / 3, inComponent: 2, animated: true)
            //secs
            self.performancePickerView.selectRow(contentsOfPerformancePicker[4].count / 3, inComponent: 4, animated: true)
            //centisecs
            self.performancePickerView.selectRow(contentsOfPerformancePicker[6].count / 3, inComponent: 6, animated: true)
        }
        else if disciplinesDistance.contains(discipline) {
            // meters
            self.performancePickerView.selectRow(contentsOfPerformancePicker[0].count / 3, inComponent: 0, animated: true)
            // centimeters
            self.performancePickerView.selectRow(contentsOfPerformancePicker[2].count / 3, inComponent: 2, animated: true)
        }
        else if disciplinesPoints.contains(discipline){
            //thousand
            self.performancePickerView.selectRow(contentsOfPerformancePicker[0].count / 3, inComponent: 0, animated: true)
            //hundred
            self.performancePickerView.selectRow(contentsOfPerformancePicker[2].count / 3, inComponent: 2, animated: true)
            //tens
            self.performancePickerView.selectRow(contentsOfPerformancePicker[3].count / 3, inComponent: 3, animated: true)
            //ones
            self.performancePickerView.selectRow(contentsOfPerformancePicker[4].count / 3, inComponent: 4, animated: true)
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

        if isValid {
            saveActivityButton.tintColor = UIColor.blueColor()
            saveActivityButton.enabled = true
        } else {
            saveActivityButton.tintColor = CLR_MEDIUM_GRAY
            saveActivityButton.enabled = false
        }
    }
    
    /// Saves activity and dismisses View
    @IBAction func saveActivityAndCloseView(sender: UIBarButtonItem) {
        Utils.dismissFirstResponder(view)

        setNotificationState(.Info, notification: statusBarNotification, style:.StatusBarNotification)
        statusBarNotification.displayNotificationWithMessage("Saving...", completion: {})
        Utils.showNetworkActivityIndicatorVisible(true)
        if sender === saveActivityButton {
            let timestamp : String = String(Utils.dateToTimestamp("\(self.dateField.text!)T\(String(self.timeFieldForDB))"))
            let _userId: String = self.userId


            /// activity to temporarly  saved in realm.
            let _activityLocal = ActivityModelObject(value: [
                "userId": _userId,
                "discipline": selectedDiscipline,
                "performance": selectedPerformance,
                "date": Utils.timestampToDate(timestamp),
                "dateUnixTimestamp": timestamp,
                "rank": self.rankField.text!,
                "location": self.locationField.text!,
                "competition": self.competitionField.text!,
                "notes": self.notesField.text!,
                "comments": self.commentsField.text!,
                "isDeleted": false,
                "isOutdoor": (self.isOutdoorSegment.selectedSegmentIndex == 0 ? false : true),
                "isPrivate": (self.isPrivateSegment.selectedSegmentIndex == 0 ? true : false),
                "isDraft": true ])

            
            /// activity to post to server
            let activity = ["discipline": selectedDiscipline,
                            "performance": selectedPerformance,
                            "date": timestamp,
                            "rank": self.rankField.text,
                            "location": self.locationField.text,
                            "competition": self.competitionField.text,
                            "notes": self.notesField.text,
                            "comments": self.commentsField.text,
                            "isOutdoor": (self.isOutdoorSegment.selectedSegmentIndex == 0 ? "false" : "true"),
                            "isPrivate": (self.isPrivateSegment.selectedSegmentIndex == 0 ? "true" : "false") ]

            switch isEditingActivity {
            case false: // ADD MODE
                enableAllViewElements(false)
                // CREATE AND SAVE A DRAFT OBJECT IN LOCALDB.
                // UPDATE IT AFTER A SUCCESFULL RESPONSE FROM SERVER.
                // create a unique id. we will remove this value after get the response from server.
                _activityLocal.activityId = NSUUID().UUIDString
                _activityLocal.update()

                Utils.showNetworkActivityIndicatorVisible(true)
                
                let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
                let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)",  "Content-Type": "application/json"]
                let endPoint: String = trafieURL + "api/users/\(userId)/activities"
                
                Alamofire.upload(
                    .POST,
                    endPoint,
                    headers: headers,
                    multipartFormData: { mfd in
                        if self.activityImageEdited, let imageData: NSMutableData = NSMutableData(data: UIImageJPEGRepresentation(self.activityImageToPost, 1)!) {
                            mfd.appendBodyPart(data: imageData, name: "picture", fileName: "activityImage.jpeg", mimeType: "image/jpeg")
                        }
                        
                        for (key, value) in activity {
                            mfd.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: key)
                        }
                        print(mfd.boundary)
                        print(mfd.contentType)
                    },
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                                print("Uploading data \(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                                dispatch_async(dispatch_get_main_queue(),{
                                    /**
                                     *  Update UI Thread about the progress
                                     */
                                })
                            }
                            upload.responseJSON { response in
                                Utils.showNetworkActivityIndicatorVisible(false)
                                if response.result.isSuccess {
                                    let responseJSONObject = JSON(response.result.value!)
                                    if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
                                        Utils.log("\(responseJSONObject)")
        
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
                                        // delete draft from realm
                                        try! uiRealm.write {
                                            uiRealm.deleteNotified(_activityLocal)
                                        }
        
                                        let _syncedActivity = ActivityModelObject(value: [
                                            "userId": responseJSONObject["userId"].stringValue,
                                            "activityId": responseJSONObject["_id"].stringValue,
                                            "discipline": responseJSONObject["discipline"].stringValue,
                                            "performance": responseJSONObject["performance"].stringValue,
                                            "date": Utils.timestampToDate(responseJSONObject["date"].stringValue),
                                            "dateUnixTimestamp": responseJSONObject["date"].stringValue,
                                            "rank": responseJSONObject["rank"].stringValue,
                                            "location": responseJSONObject["location"].stringValue,
                                            "competition": responseJSONObject["competition"].stringValue,
                                            "notes": responseJSONObject["notes"].stringValue,
                                            "comments": responseJSONObject["comments"].stringValue,
                                            "isDeleted": responseJSONObject["isDeleted"] ? true : false,
                                            "isOutdoor": responseJSONObject["isOutdoor"] ? true : false,
                                            "isPrivate": responseJSONObject["isPrivate"] ? true : false,
                                            "imageUrl": responseJSONObject["picture"].stringValue,
                                            "isDraft": false ])
                                        // save activity from server
                                        _syncedActivity.update()
        
                                        SweetAlert().showAlert("You rock!", subTitle: "Your activity has been saved!", style: AlertStyle.Success)
                                        Utils.log("Activity Synced: \(_syncedActivity)")
        
                                        self.dismissViewControllerAnimated(false, completion: {})
                                    } else {
                                        if let errorCode = responseJSONObject["errors"][0]["code"].string { //under 403 statusCode
                                            if errorCode == "non_verified_user_activity_limit" {
                                                SweetAlert().showAlert("Email not verified.", subTitle: "Go to your profile and verify you email so you can add more activities.", style: AlertStyle.Warning)
                                            } else {
                                                Utils.log(String(response))
                                                SweetAlert().showAlert("Ooops.", subTitle: errorCode, style: AlertStyle.Error)
                                            }
                                        }
                                    }
                                } else if response.result.isFailure {
                                    Utils.log("Request failed with error: \(response.result)")
                                    SweetAlert().showAlert("Saved locally.", subTitle: "Activity saved only in your phone. Try to sync when internet is available.", style: AlertStyle.Warning)
                                    self.dismissViewControllerAnimated(false, completion: {})
                                    if let data = response.data {
                                        Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                                    }
                                }
                                self.enableAllViewElements(true)
                                // Dismissing status bar notification
                                statusBarNotification.dismissNotification()
                        }
                        case .Failure(let error):
                            Utils.log("FAIL: " +  String(error))
                            // Dismissing status bar notification
                            statusBarNotification.dismissNotification()
                            SweetAlert().showAlert("Ooops.", subTitle: String(error), style: AlertStyle.Error)
                        }
                })
   
            default: // EDIT MODE
                enableAllViewElements(false)
                let oldActivity = uiRealm.objectForPrimaryKey(ActivityModelObject.self, key: editingActivityID)
                // CREATE AND SAVE A DRAFT OBJECT IN LOCALDB.
                // UPDATE IT AFTER A SUCCESFULL RESPONSE FROM SERVER.
                _activityLocal.activityId = oldActivity?.activityId
                _activityLocal.update()

                Utils.showNetworkActivityIndicatorVisible(true)

                let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!
                let headers: [String : String]? = ["Authorization": "Bearer \(accessToken)",  "Content-Type": "application/json"]
                let endPoint: String = trafieURL + "api/users/\(userId)/activities/\(editingActivityID)"
                
                Alamofire.upload(
                    .PUT,
                    endPoint,
                    headers: headers,
                    multipartFormData: { mfd in
                        if self.activityImageEdited, let imageData: NSMutableData = NSMutableData(data: UIImageJPEGRepresentation(self.activityImageToPost, 1)!) {
                            mfd.appendBodyPart(data: imageData, name: "picture", fileName: "activityImage.jpeg", mimeType: "image/jpeg")
                        }
                        
                        for (key, value) in activity {
                            mfd.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: key)
                        }
                        print(mfd.boundary)
                        print(mfd.contentType)
                    },
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                                print("Uploading data \(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                                dispatch_async(dispatch_get_main_queue(),{
                                    /**
                                     *  Update UI Thread about the progress
                                     */
                                })
                            }
                            upload.responseJSON { response in
                                Utils.showNetworkActivityIndicatorVisible(false)
                                if response.result.isSuccess {
                                    
                                    var responseJSONObject = JSON(response.result.value!)
                                    if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
                                        Utils.log("Success")
                                        Utils.log("\(responseJSONObject)")
                                        
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        let _syncedActivity = ActivityModelObject(value: [
                                            "userId": responseJSONObject["userId"].stringValue,
                                            "activityId": responseJSONObject["_id"].stringValue,
                                            "discipline": responseJSONObject["discipline"].stringValue,
                                            "performance": responseJSONObject["performance"].stringValue,
                                            "date": Utils.timestampToDate(responseJSONObject["date"].stringValue),
                                            "dateUnixTimestamp": responseJSONObject["date"].stringValue,
                                            "rank": responseJSONObject["rank"].stringValue,
                                            "location": responseJSONObject["location"].stringValue,
                                            "competition": responseJSONObject["competition"].stringValue,
                                            "notes": responseJSONObject["notes"].stringValue,
                                            "comments": responseJSONObject["comments"].stringValue,
                                            "imageUrl": responseJSONObject["picture"].stringValue,
                                            "isDeleted": responseJSONObject["isDeleted"] ? true : false,
                                            "isOutdoor": responseJSONObject["isOutdoor"] ? true : false,
                                            "isPrivate": responseJSONObject["isPrivate"] ? true : false,
                                            "isDraft": false ])
                                        
                                        _syncedActivity.update()
                                        
                                        Utils.log("Activity Edited: \(_syncedActivity)")
                                        SweetAlert().showAlert("Sweet!", subTitle: "That's right! \n Activity has been edited.", style: AlertStyle.Success)
                                        
                                        editingActivityID = ""
                                        isEditingActivity = false
                                        self.dismissViewControllerAnimated(false, completion: {})
                                    } else if Utils.validateTextWithRegex(StatusCodesRegex._404.rawValue, text: String((response.response!.statusCode))) {
                                        self.enableAllViewElements(true)
                                        editingActivityID = ""
                                        isEditingActivity = false
                                        SweetAlert().showAlert("Activity doesn't exist.", subTitle: "Activity doesn't exists in our server. Delete it from your phone.", style: AlertStyle.Warning)
                                        self.dismissViewControllerAnimated(false, completion: {})
                                    } else {
                                        Utils.log(String(response))
                                        SweetAlert().showAlert("Ooops.", subTitle: String((response.response!.statusCode)), style: AlertStyle.Error)
                                    }
                                } else if response.result.isFailure {
                                    Utils.log("Request failed with error: \(response.result.error)")
                                    self.enableAllViewElements(true)
                                    SweetAlert().showAlert("Saved locally.", subTitle: "Activity saved only in your phone. Try to sync when internet is available.", style: AlertStyle.Warning)
                                    editingActivityID = ""
                                    isEditingActivity = false
                                    self.dismissViewControllerAnimated(false, completion: {})
                                    if let data = response.data {
                                        Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                                    }
                                }
                                
                                NSNotificationCenter.defaultCenter().postNotificationName("reloadActivity", object: nil)
                                self.enableAllViewElements(true)
                                // Dismissing status bar notification
                                statusBarNotification.dismissNotification()
                                Utils.showNetworkActivityIndicatorVisible(false)
                            }
                        case .Failure(let encodingError):
                            Utils.log("FAIL: " +  String(encodingError))
                            // Dismissing status bar notification
                            statusBarNotification.dismissNotification()
                            SweetAlert().showAlert("Ooops.", subTitle: String(encodingError), style: AlertStyle.Error)
                        }
                })
            }
        }
        else {
            Utils.log("There is something wrong with this form...")
        }
    }
    
    /// Called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        Utils.dismissFirstResponder(view)
        return true;
    }
    
    /// Disables all view elements. Used while loading.
    func enableAllViewElements(isEnabled: Bool) {
        self.dateField.enabled = isEnabled
        self.timeField.enabled = isEnabled
        self.rankField.enabled = isEnabled
        self.competitionField.enabled = isEnabled
        self.locationField.enabled = isEnabled
        self.notesField.editable = isEnabled
        self.commentsField.editable = isEnabled
        self.performancePickerView.userInteractionEnabled = isEnabled
        self.disciplinesPickerView.userInteractionEnabled = isEnabled
        self.saveActivityButton.enabled = isEnabled
        self.dismissViewButton.enabled = isEnabled
    }

    /// Function called from all "done" buttons of keyboards and pickers.
    func doneButton(sender: UIButton) {
        Utils.dismissFirstResponder(view)
    }
    
    // MARK: Image upload
    @IBAction func selectPicture(sender: AnyObject) {
        let cameraViewController = CameraViewController(croppingEnabled: false) { [weak self] image, asset in
            if image != nil {
                let screenSize: CGRect = UIScreen.mainScreen().bounds
                self!.activityImage.image = Utils.ResizeImageToFitWidth(image!, width: screenSize.width)
                self!.activityImageToPost = image!
                self!.activityImageEdited = true
            }
            self?.dismissViewControllerAnimated(true, completion: nil)
            self!.tableView.reloadData()
        }
        
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    // MARK: TableView Settings
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 { //section 1
            switch indexPath.row {
            case 0: //discipline
                return 73.0
            case 1: //performance
                return 120.0
            default: //
                return 44.0
            }
        } else if indexPath.section == 1 {
            if ((self.activityImage.image) != nil) {
                return (self.activityImage.image?.size.height)!
            } else {
                return 120
            }
        } else if indexPath.section == 3 || indexPath.section == 4 { //section 4, 5
            return 100.0
        } else { //section 2, 5
            return 44.0
        }
        
    }
    
}
