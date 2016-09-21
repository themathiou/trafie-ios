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
  
  override func viewDidAppear(_ animated: Bool) {
    
    let userId = UserDefaults.standard.object(forKey: "userId") as! String
    let token = UserDefaults.standard.object(forKey: "token") as! String
    let loginVC = self.storyboard!.instantiateViewController(withIdentifier: "loginPage")
    let activitiesView = self.storyboard!.instantiateViewController(withIdentifier: "mainTabBarViewController")
    
    //No User Info
    if userId == "" || token == ""{
      try! uiRealm.write {
        uiRealm.deleteAll()
      }
      self.present(loginVC, animated: true, completion: nil)
    } else { // User Info. Check Network and handle login cases.
      let status = Reach().connectionStatus()
      
      switch status {
      case .unknown, .offline:
        self.present(activitiesView, animated: true, completion: nil)
      case .online(.wwan), .online(.wiFi):
        getLocalUserSettings(userId)
          .then { promise -> Void in
            if promise == .Success {
              self.present(activitiesView, animated: true, completion: nil)
              DBInterfaceHandler.fetchUserActivitiesFromServer(userId, updatedFrom: "")
            } else if promise == .Unauthorised {
              Utils.clearLocalUserData()
              self.present(loginVC, animated: true, completion: nil)
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
