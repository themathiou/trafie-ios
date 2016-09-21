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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    
    let name = "iOS : About[\(legalPageToBeViewed.rawValue)] ViewController"
    Utils.googleViewHitWatcher(name);
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
    
    let url = URL(string: "https://www.trafie.com/\(legalPageToBeViewed.rawValue)")
    let request = URLRequest(url: url!)
    
    webView.loadRequest(request)
  }
  
  @IBAction func dismissView(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: {})
  }
}
