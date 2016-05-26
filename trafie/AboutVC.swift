//
//  AboutVC.swift
//  trafie
//
//  Created by mathiou on 18/03/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit

class LegalVC : UIViewController {
    
    @IBOutlet weak var webView: UIWebView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let name = "iOS : About[\(legalPageToBeViewed.rawValue)] ViewController"
        
        // [START screen_view_hit_swift]
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        // [END screen_view_hit_swift]
    }

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
