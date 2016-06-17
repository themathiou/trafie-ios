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

        if userId == "" {
            // TODO: consider if need to remove specific user's only data
            try! uiRealm.write {
                uiRealm.deleteAll()
            }
            let loginVC = self.storyboard!.instantiateViewControllerWithIdentifier("loginPage")
            self.presentViewController(loginVC, animated: true, completion: nil)
        } else {
            DBInterfaceHandler.fetchUserActivitiesFromServer(userId, updatedFrom: "", isDeleted:"true")
            let activitiesView = self.storyboard!.instantiateViewControllerWithIdentifier("mainTabBarViewController")
            self.presentViewController(activitiesView, animated: true, completion: nil)
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