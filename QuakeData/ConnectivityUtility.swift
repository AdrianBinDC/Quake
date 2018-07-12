//
//  ConnectivityUtility.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/10/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import Reachability

/*
 Need Reachability Cocoapod
 
 https://github.com/ashleymills/Reachability.swift
 
 Usage:
 * On ViewController, declare optional var, as follows...
 
 var reachability: ConnectivityUtil?
 
 * Implement delegate methods
 
 * In viewDidLoad/viewWillAppear, instantiate it:
 
 override func viewWillAppear(_ animated: Bool) {
   super.viewWillAppear(animated)
   self.reachability = ConnectivityUtil(delegate: self)
 }

 */

protocol ConnectivityUtilDelegate: class {
  func postAlert(title: String, message: String)
  func postWarning(title: String, message: String)
}

class ConnectivityUtil: NSObject {
  
  private let reachability = Reachability()!
  
  weak var delegate: ConnectivityUtilDelegate?
  
  init(delegate: ConnectivityUtilDelegate) {
    super.init()
    self.delegate = delegate
    setReachabilityNotifier()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
  }
  
  private func setReachabilityNotifier () {
    //declare this inside of viewWillAppear
    guard let delegate = delegate else { return }
    NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
    do{
      try reachability.startNotifier()
    }catch{
      delegate.postWarning(title: "Warning", message: "Could not start reachability notifier")
    }
  }
  
  @objc private func reachabilityChanged(note: Notification) {
    
    let reachability = note.object as! Reachability
    
    switch reachability.connection {
    case .wifi:
      delegate?.postAlert(title: "Connected", message: "Connected via WiFi")
    case .cellular:
      delegate?.postAlert(title: "Connected", message: "Connected via Cellular")
    case .none:
      delegate?.postWarning(title: "Warning", message: "Network not reachable")
    }
  }
}
