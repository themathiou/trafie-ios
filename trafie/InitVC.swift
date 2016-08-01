//
//  InitVC.swift
//  trafie
//
//  Created by mathiou on 15/06/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift


class InitVC: UIViewController {
  
  override func viewDidAppear(animated: Bool) {
    
    let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
    let token = NSUserDefaults.standardUserDefaults().objectForKey("token") as! String
    let loginVC = self.storyboard!.instantiateViewControllerWithIdentifier("loginPage")
    let activitiesView = self.storyboard!.instantiateViewControllerWithIdentifier("mainTabBarViewController")
    
    //No User Info
    if userId == "" || token == ""{
      try! uiRealm.write {
        uiRealm.deleteAll()
      }
      self.presentViewController(loginVC, animated: true, completion: nil)
    } else { // User Info. Check Network and handle login cases.
      let status = Reach().connectionStatus()
      
      switch status {
      case .Unknown, .Offline:
        self.presentViewController(activitiesView, animated: true, completion: nil)
      case .Online(.WWAN), .Online(.WiFi):
        getLocalUserSettings(userId)
          .then { promise -> Void in
            if promise == .Success {
              self.presentViewController(activitiesView, animated: true, completion: nil)
              DBInterfaceHandler.fetchUserActivitiesFromServer(userId, updatedFrom: "")
            } else if promise == .Unauthorised {
              Utils.clearLocalUserData()
              self.presentViewController(loginVC, animated: true, completion: nil)
            }
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}