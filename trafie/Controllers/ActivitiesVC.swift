

//
//  ActivitiesViewController.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift


class ActivitiesVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, RealmResultsControllerDelegate  {
  
  // MARK:- Outlets and Variables
  @IBOutlet weak var activitiesTableView: UITableView!
  @IBOutlet weak var addActivityBarButton: UIBarButtonItem!  
  @IBOutlet weak var emptyStateView: UIView!

  private let animationController = DAExpandAnimation()
  
  var refreshControl: UIRefreshControl = UIRefreshControl()
  var addActivityVC: UINavigationController!
  var userId : String = ""
  
  
  var rrc: RealmResultsController<ActivityModelObject, ActivityObject>?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLayoutSubviews() {
    self.refreshControl.superview!.sendSubviewToBack(self.refreshControl)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    
    self.userId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
    
    let name = "iOS : Activities ViewController"
    Utils.googleViewHitWatcher(name);
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Notification Events
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ActivitiesVC.recalculateActivities(_:)), name:"recalculateActivities", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ActivitiesVC.showConnectionStatusChange(_:)), name: ReachabilityStatusChangedNotification, object: nil)
    
    Utils.log("\(Reach().connectionStatus())")
    
    //initialize editable mode to false.
    isEditingActivity = false
    self.userId = (NSUserDefaults.standardUserDefaults().objectForKey("userId") as? String)!
    
    self.activitiesTableView.delegate = self
    self.activitiesTableView.dataSource = self
    //get user's activities
    self.emptyStateView.hidden = true
    loadActivities(self.userId)
    
    self.activitiesTableView.estimatedRowHeight = 100
    self.activitiesTableView.rowHeight = UITableViewAutomaticDimension //automatic resize cells
    self.activitiesTableView.contentInset = UIEdgeInsetsZero //table view reaches the ui edges
    self.activitiesTableView.tableFooterView = UIView() // A little trick for removing the cell separators
    
    // View Controllers
    addActivityVC = self.storyboard?.instantiateViewControllerWithIdentifier("AddEditActivityController") as! UINavigationController
    
    
    //Pull down to refresh
    self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    self.refreshControl.addTarget(self, action: #selector(ActivitiesVC.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    self.activitiesTableView.addSubview(refreshControl)
    
    ///Realm
    let request = RealmRequest<ActivityModelObject>(predicate: NSPredicate(value: true), realm: uiRealm, sortDescriptors: [SortDescriptor(property: "year").reversed(), SortDescriptor(property: "date").reversed()])
    rrc = try! RealmResultsController<ActivityModelObject, ActivityObject>(request: request, sectionKeyPath: "year", mapper: ActivityObject.map)
    rrc!.delegate = self
    rrc!.performFetch()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: Table view protocols
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    let num: Int = (rrc != nil) ? rrc!.numberOfSections : 0
    // toggle empty state view
    self.emptyStateView.hidden = (num == 0) ? false : true
    
    return num
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let num: Int = (rrc != nil) ? rrc!.numberOfObjectsAt(section) : 0
    return num
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("activityTableCell") as! ActivtitiesTableViewCell
    
    let activity = rrc!.objectAt(indexPath)
    
    dateFormatter.dateFormat = "MMM d YYYY"
    let finalDate: String = dateFormatter.stringFromDate(activity.date)
    
    cell.performanceLabel.text = activity.readablePerformance
    cell.competitionLabel.text = activity.competition
    cell.dateLabel.text = finalDate
    cell.notSyncedLabel.hidden = !activity.isDraft
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
    let cellToSelect:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
    cellToSelect.contentView.backgroundColor = UIColor.whiteColor()
    
    let _activity: ActivityObject = rrc!.objectAt(indexPath)
    viewingActivityID = _activity.activityId!
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let keyPath: String = (rrc != nil) ? rrc!.sections[section].keyPath : "Year..."
    return "\(keyPath)"
  }
  
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  /// Prompts a confirmation message to user and, if he confirms the request, deletes the activity.
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.Delete) {
      let _tmpactivity = rrc!.objectAt(indexPath)
      let _activity = uiRealm.objectForPrimaryKey(ActivityModelObject.self, key: _tmpactivity.activityId!)!
      
      // Activity exists only locally. There is no copy in server yet. So it can be deleted.
      if ((_tmpactivity.activityId?.containsString("-")) != false) {
        SweetAlert().showAlert("Delete Activity", subTitle: "Are you sure you want to delete your performance from \"\(_activity.competition!)\"?", style: AlertStyle.Warning, buttonTitle:"Keep it", buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Delete it", otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
          if isOtherButton == true {
            Utils.log("Deletion Cancelled")
          }
          else {
            try! uiRealm.write {
              uiRealm.deleteNotified(_activity)
            }
          }
        }
      } else { // Activity Exists also in server. We need network to delete it.
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
          SweetAlert().showAlert("You are offline!", subTitle: "You cannot delete synced activities when offline! Try again when internet is available!", style: AlertStyle.Warning)
        case .Online(.WWAN), .Online(.WiFi):
          let _activity = uiRealm.objectForPrimaryKey(ActivityModelObject.self, key: _tmpactivity.activityId!)!
          SweetAlert().showAlert("Delete Activity", subTitle: "Are you sure you want to delete your performance from \"\(_activity.competition!)\"?", style: AlertStyle.Warning, buttonTitle:"Keep it", buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Delete it", otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
            if isOtherButton == true {
              Utils.log("Deletion Cancelled")
            }
            else {
              setNotificationState(.Info, notification: statusBarNotification, style:.StatusBarNotification)
              statusBarNotification.displayNotificationWithMessage("Deleting...", completion: {})
              Utils.showNetworkActivityIndicatorVisible(true)
              
              ApiHandler.deleteActivityById(self.userId, activityId: _activity.activityId!)
                .responseJSON { response in
                  Utils.showNetworkActivityIndicatorVisible(false)
                  // Dismissing status bar notification
                  statusBarNotification.dismissNotification()
                  
                  if response.result.isSuccess {
                    if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
                      Utils.log("Activity \"\(_activity.activityId!)\" Deleted Succesfully")
                      
                      try! uiRealm.write {
                        uiRealm.deleteNotified(_activity)
                      }
                      
                    } else {
                      SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                    }
                  } else if response.result.isFailure {
                    Utils.log("Request for deletion failed with error: \(response.result.error)")
                    SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.Error)
                    if let data = response.data {
                      Utils.log("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                  }
              }
            }
          }
        }
      }
    }
  }
  
  // MARK: RealmResult
  func willChangeResults(controller: AnyObject) {
    activitiesTableView.beginUpdates()
  }
  
  func didChangeObject<U>(controller: AnyObject, object: U, oldIndexPath: NSIndexPath, newIndexPath: NSIndexPath, changeType: RealmResultsChangeType) {
    Utils.log("🎁 didChangeObject '\((object as! ActivityModelObject).competition)' from: [\(oldIndexPath.section):\(oldIndexPath.row)] to: [\(newIndexPath.section):\(newIndexPath.row)] --> \(changeType)")
    switch changeType {
    case .Delete:
      activitiesTableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
      break
    case .Insert:
      activitiesTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      break
    case .Move:
      activitiesTableView.deleteRowsAtIndexPaths([oldIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      activitiesTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      break
    case .Update:
      activitiesTableView.reloadRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      break
    }
  }
  
  func didChangeSection<U>(controller: AnyObject, section: RealmSection<U>, index: Int, changeType: RealmResultsChangeType) {
    Utils.log("🎁 didChangeSection \(index) --> \(changeType)")
    switch changeType {
    case .Delete:
      activitiesTableView.deleteSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
      break
    case .Insert:
      activitiesTableView.insertSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
      break
    default:
      break
    }
  }
  
  func didChangeResults(controller: AnyObject) {
    activitiesTableView.endUpdates()
  }
  
  
  /**
   Checks the number of activities and if user has validate his email.
   If both are true allows him to create new activity
   */
  @IBAction func openAddActivity(sender: AnyObject) {
    let isVerified: Bool = NSUserDefaults.standardUserDefaults().boolForKey("isVerified")
    if !isVerified && uiRealm.objects(ActivityModelObject).count == MAX_NUMBER_OF_ACTIVITIES_BEFORE_VERIFIED {
      SweetAlert().showAlert("Email not verified.", subTitle: "Go to your profile and verify you email so you can add more than \(MAX_NUMBER_OF_ACTIVITIES_BEFORE_VERIFIED) activities.", style: AlertStyle.Error)
    } else {
      let next = self.storyboard!.instantiateViewControllerWithIdentifier("AddEditActivityController")
      self.presentViewController(next, animated: true, completion: nil)
    }
  }
  
  
  // MARK:- Network Connection
  /**
   Calls Utils function for network change indication
   
   - Parameter notification : notification event
   */
  @objc func showConnectionStatusChange(notification: NSNotification) {
    Utils.showConnectionStatusChange()
  }
  
  // MARK:- Table View Methods
  
  /**
   Checks the number of activities and if user has validate his email.
   If both are true allows him to create new activity
   */
  @IBAction func syncActivities(sender: AnyObject) {
    DBInterfaceHandler.fetchUserActivitiesFromServer(self.userId, updatedFrom: "")
  }
  
  /**
   Request all activities of user from server.
   If is refreshing shows an indication.
   
   - Parameter userId: the id of user we want to fetch the activities
   - Parameter isRefreshing: boolean for refreshing state. Default false.
   */
  func loadActivities(userId : String, isRefreshing : Bool?=false) {
    /// We request data from server only with unix timestamp
    let lastFetchTimestamp: String = lastFetchingActivitiesDate != "" ?
      String(Utils.dateToTimestamp(lastFetchingActivitiesDate.stringByReplacingOccurrencesOfString(" ", withString: "T"))) : ""
    
    Utils.showNetworkActivityIndicatorVisible(true)
    DBInterfaceHandler.fetchUserActivitiesFromServer(self.userId, updatedFrom: lastFetchTimestamp)
    self.refreshControl.endRefreshing()
  }
  
  /**
   Called from notification event in order to update the activities' reabable performance to user's measurementUnit.
   */
  @objc private func recalculateActivities(notification: NSNotification) {
    let activities = uiRealm.objects(ActivityModelObject)
    for activity in activities {
      activity.update()
    }
  }
  
  /**
   Called when activity list is going to be refreshed. Checks the connectivity
   and adjust accordingly the ui of refreshController.
   */
  func refresh(sender:AnyObject)
  {
    let status = Reach().connectionStatus()
    switch status {
    case .Unknown, .Offline:
      self.refreshControl.attributedTitle = NSAttributedString(string: "No Internet Connection")
      self.refreshControl.endRefreshing()
    default:
      self.refreshControl.attributedTitle = NSAttributedString(string: "Last Update: " + lastFetchingActivitiesDate)
      loadActivities(self.userId, isRefreshing: true)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let toViewController = segue.destinationViewController
    
    if let selectedCell = sender as? UITableViewCell {
      toViewController.transitioningDelegate = self
      toViewController.modalPresentationStyle = .Custom
      toViewController.view.backgroundColor = UIColor.blackColor()
      
      animationController.collapsedViewFrame = {
        return selectedCell.frame
      }
      animationController.animationDuration = 0.5
      
      if let indexPath = activitiesTableView.indexPathForCell(selectedCell) {
        activitiesTableView.deselectRowAtIndexPath(indexPath, animated: false)
      }
    }
  }
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return animationController
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return animationController
  }

}