//
//  BaseViewController.swift
//  BanglaDictionary
//
//  Created by MacBook Pro on 11/29/16.
//  Copyright © 2016 MacMan. All rights reserved.
//

import UIKit
import ReachabilitySwift

class BaseViewController: UIViewController {
    let reachability = Reachability()!
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Network not reachable")
        }
    }
    
    
}
