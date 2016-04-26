//
//  AboutVC.swift
//  trafie
//
//  Created by mathiou on 18/03/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class LegalVC : UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch legalPageToBeViewed {
        case LegalPages.About:
            self.navigationItem.title = "About"
        case LegalPages.Terms:
            self.navigationItem.title = "Terms"
        case LegalPages.Privacy:
            self.navigationItem.title = "Privacy"
        }

        let url = NSURL(string: "https://www.trafie.com/\(legalPageToBeViewed.rawValue)")
        let request = NSURLRequest(URL: url!)
        
        webView.loadRequest(request)
    }
    
    @IBAction func dismissView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}
