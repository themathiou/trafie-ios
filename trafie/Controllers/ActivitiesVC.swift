

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

  //fileprivate let animationController = DAExpandAnimation()
  
  var refreshControl: UIRefreshControl = UIRefreshControl()
  var addActivityVC: UINavigationController!
  var userId : String = ""
  
  
  var rrc: RealmResultsController<ActivityModelObject, ActivityObject>?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLayoutSubviews() {
    self.refreshControl.superview!.sendSubview(toBack: self.refreshControl)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    
    self.userId = UserDefaults.standard.object(forKey: "userId") as! String
    
    let name = "iOS : Activities ViewController"
    Utils.googleViewHitWatcher(name);
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Notification Events
    NotificationCenter.default.addObserver(self, selector: #selector(ActivitiesVC.recalculateActivities(_:)), name:NSNotification.Name(rawValue: "recalculateActivities"), object: nil)
    
    Utils.log("\(Reach().connectionStatus())")
    
    //initialize editable mode to false.
    isEditingActivity = false
    self.userId = (UserDefaults.standard.object(forKey: "userId") as? String)!
    
    self.activitiesTableView.delegate = self
    self.activitiesTableView.dataSource = self
    //get user's activities
    self.emptyStateView.isHidden = true
    loadActivities(self.userId)
    
    self.activitiesTableView.estimatedRowHeight = 100
    self.activitiesTableView.rowHeight = UITableViewAutomaticDimension //automatic resize cells
    self.activitiesTableView.contentInset = UIEdgeInsets.zero //table view reaches the ui edges
    self.activitiesTableView.tableFooterView = UIView() // A little trick for removing the cell separators
    
    // View Controllers
    addActivityVC = self.storyboard?.instantiateViewController(withIdentifier: "AddEditActivityController") as! UINavigationController
    
    
    //Pull down to refresh
    self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    self.refreshControl.addTarget(self, action: #selector(ActivitiesVC.refresh(_:)), for: UIControlEvents.valueChanged)
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
  
  func numberOfSections(in tableView: UITableView) -> Int {
    let num: Int = (rrc != nil) ? rrc!.numberOfSections : 0
    // toggle empty state view
    self.emptyStateView.isHidden = (num == 0) ? false : true
    
    return num
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let num: Int = (rrc != nil) ? rrc!.numberOfObjects(at: section) : 0
    return num
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "activityTableCell") as! ActivtitiesTableViewCell
    
    let activity = rrc!.object(at: indexPath)
    
    dateFormatter.dateFormat = "MMM d YYYY"
    let finalDate: String = dateFormatter.string(from: activity.date)
    
    cell.performanceLabel.text = activity.readablePerformance
    cell.competitionLabel.text = activity.competition
    cell.dateLabel.text = finalDate
    cell.notSyncedLabel.isHidden = !activity.isDraft
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    let cellToSelect:UITableViewCell = tableView.cellForRow(at: indexPath)!
    cellToSelect.contentView.backgroundColor = UIColor.white
    
    let _activity: ActivityObject = rrc!.object(at: indexPath)
    viewingActivityID = _activity.activityId!
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let text: String = rrc!.sections[section].keyPath
    return Utils.fixOptionalString(text)
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  /// Prompts a confirmation message to user and, if he confirms the request, deletes the activity.
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.delete) {
      let _tmpactivity = rrc!.object(at: indexPath)
      let _activity = uiRealm.object(ofType: ActivityModelObject.self, forPrimaryKey: _tmpactivity.activityId! as AnyObject)!
      
      // Activity exists only locally. There is no copy in server yet. So it can be deleted.
      if ((_tmpactivity.activityId?.contains("-")) != false) {
        SweetAlert().showAlert("Delete Activity", subTitle: "Are you sure you want to delete your performance from \"\(_activity.competition!)\"?", style: AlertStyle.warning, buttonTitle:"Keep it", buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Delete it", otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
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
        case .unknown, .offline:
          SweetAlert().showAlert("You are offline!", subTitle: "You cannot delete synced activities when offline! Try again when internet is available!", style: AlertStyle.warning)
        case .online(.wwan), .online(.wiFi):
          let _activity = uiRealm.object(ofType: ActivityModelObject.self, forPrimaryKey: _tmpactivity.activityId! as AnyObject)!
          SweetAlert().showAlert("Delete Activity", subTitle: "Are you sure you want to delete your performance from \"\(_activity.competition!)\"?", style: AlertStyle.warning, buttonTitle:"Keep it", buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Delete it", otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
            if isOtherButton == true {
              Utils.log("Deletion Cancelled")
            }
            else {
              showWhisper(.Warning, message: "Deleting", navigationController: self.navigationController!)
              Utils.showNetworkActivityIndicatorVisible(true)
              
              ApiHandler.deleteActivityById(userId: self.userId, activityId: _activity.activityId!)
                .responseJSON { response in
                  Utils.showNetworkActivityIndicatorVisible(false)
                  // Dismissing status bar notification

                  if response.result.isSuccess {
                    if Utils.validateTextWithRegex(StatusCodesRegex._200.rawValue, text: String((response.response!.statusCode))) {
                      Utils.log("Activity \"\(_activity.activityId!)\" Deleted Succesfully")
                      
                      try! uiRealm.write {
                        uiRealm.deleteNotified(_activity)
                      }
                      
                    } else {
                      SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.error)
                    }
                  } else if response.result.isFailure {
                    Utils.log("Request for deletion failed with error: \(response.result.error)")
                    SweetAlert().showAlert("Ooops.", subTitle: "Something went wrong. \n Please try again.", style: AlertStyle.error)
                    if let data = response.data {
                      Utils.log("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                    }
                  }
                  hideWhisper(navigationController: self.navigationController!)
              }
            }
          }
        }
      }
    }
  }
  
  // MARK: RealmResult
  func willChangeResults(_ controller: AnyObject) {
    activitiesTableView.beginUpdates()
  }
  
  func didChangeObject<U>(_ controller: AnyObject, object: U, oldIndexPath: IndexPath, newIndexPath: IndexPath, changeType: RealmResultsChangeType) {
    Utils.log("🎁 didChangeObject '\((object as! ActivityModelObject).competition)' from: [\((oldIndexPath as NSIndexPath).section):\((oldIndexPath as NSIndexPath).row)] to: [\((newIndexPath as NSIndexPath).section):\((newIndexPath as NSIndexPath).row)] --> \(changeType)")
    switch changeType {
    case .Delete:
      activitiesTableView.deleteRows(at: [newIndexPath], with: UITableViewRowAnimation.fade)
      break
    case .Insert:
      activitiesTableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.automatic)
      break
    case .Move:
      activitiesTableView.deleteRows(at: [oldIndexPath], with: UITableViewRowAnimation.automatic)
      activitiesTableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.automatic)
      break
    case .Update:
      activitiesTableView.reloadRows(at: [newIndexPath], with: UITableViewRowAnimation.automatic)
      break
    }
  }
  
  func didChangeSection<U>(_ controller: AnyObject, section: RealmSection<U>, index: Int, changeType: RealmResultsChangeType) {
    Utils.log("🎁 didChangeSection \(index) --> \(changeType)")
    switch changeType {
    case .Delete:
      activitiesTableView.deleteSections(IndexSet(integer: index), with: UITableViewRowAnimation.automatic)
      break
    case .Insert:
      activitiesTableView.insertSections(IndexSet(integer: index), with: UITableViewRowAnimation.automatic)
      break
    default:
      break
    }
  }
  
  func didChangeResults(_ controller: AnyObject) {
    activitiesTableView.endUpdates()
  }
  
  
  /**
   Checks the number of activities and if user has validate his email.
   If both are true allows him to create new activity
   */
  @IBAction func openAddActivity(_ sender: AnyObject) {
    let isVerified: Bool = UserDefaults.standard.bool(forKey: "isVerified")
    if !isVerified && uiRealm.objects(ActivityModelObject).count == MAX_NUMBER_OF_ACTIVITIES_BEFORE_VERIFIED {
      SweetAlert().showAlert("Email not verified.", subTitle: "Go to your profile and verify you email so you can add more than \(MAX_NUMBER_OF_ACTIVITIES_BEFORE_VERIFIED) activities.", style: AlertStyle.error)
    } else {
      let next = self.storyboard!.instantiateViewController(withIdentifier: "AddEditActivityController")
      self.present(next, animated: true, completion: nil)
    }
  }
  
  // MARK:- Table View Methods
  
  /**
   Checks the number of activities and if user has validate his email.
   If both are true allows him to create new activity
   */
  @IBAction func syncActivities(_ sender: AnyObject) {
    showWhisper(.Info, message: "syncing", navigationController: self.navigationController!)
    DBInterfaceHandler.fetchUserActivitiesFromServer(self.userId, updatedFrom: "")
    hideWhisper(navigationController: self.navigationController!)
  }
  
  /**
   Request all activities of user from server.
   If is refreshing shows an indication.
   
   - Parameter userId: the id of user we want to fetch the activities
   - Parameter isRefreshing: boolean for refreshing state. Default false.
   */
  func loadActivities(_ userId : String, isRefreshing : Bool?=false) {
    /// We request data from server only with unix timestamp
    let lastFetchTimestamp: String = lastFetchingActivitiesDate != "" ?
      String(Utils.dateToTimestamp(lastFetchingActivitiesDate.replacingOccurrences(of: " ", with: "T"))) : ""
    
    Utils.showNetworkActivityIndicatorVisible(true)
    DBInterfaceHandler.fetchUserActivitiesFromServer(self.userId, updatedFrom: lastFetchTimestamp)
    self.refreshControl.endRefreshing()
  }
  
  /**
   Called from notification event in order to update the activities' reabable performance to user's measurementUnit.
   */
  @objc fileprivate func recalculateActivities(_ notification: Foundation.Notification) {
    let activities = uiRealm.objects(ActivityModelObject.self)
    for activity in activities {
      activity.update()
    }
  }
  
  /**
   Called when activity list is going to be refreshed. Checks the connectivity
   and adjust accordingly the ui of refreshController.
   */
  func refresh(_ sender:AnyObject)
  {
    let status = Reach().connectionStatus()
    switch status {
    case .unknown, .offline:
      self.refreshControl.attributedTitle = NSAttributedString(string: "No Internet Connection")
      self.refreshControl.endRefreshing()
    default:
      self.refreshControl.attributedTitle = NSAttributedString(string: "Last Update: " + lastFetchingActivitiesDate)
      loadActivities(self.userId, isRefreshing: true)
    }
  }
  
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    let toViewController = segue.destination
    
//    if let selectedCell = sender as? UITableViewCell {
//      toViewController.transitioningDelegate = self
//      toViewController.modalPresentationStyle = .custom
//      toViewController.view.backgroundColor = UIColor.black
//      
      //TODO: fix
      //animationController.collapsedViewFrame = {
//        return selectedCell.frame
//      }
      //animationController.animationDuration = 0.5
      
//      if let indexPath = activitiesTableView.indexPath(for: selectedCell) {
//        activitiesTableView.deselectRow(at: indexPath, animated: false)
//      }
//    }
//  }

//  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//    return animationController
//  }
//  
//  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//    return animationController
//  }

}
