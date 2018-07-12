//
//  FilterViewController.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/11/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
  
  @IBOutlet weak var closeButton: UIBarButtonItem!
  
  let mapRegionUtility = MapRegionUtility()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    let array = mapRegionUtility.countryTableViewDataSource()
    print(array)
  }
  
  
  // MARK: IBActions
  
  @IBAction func closeButtonAction(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
}
