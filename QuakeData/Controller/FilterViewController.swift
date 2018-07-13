//
//  FilterViewController.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/11/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit

// TODO: configure UI, add animations where appropriate
// TODO: add backgrounds to sections

protocol FilterViewControllerDelegate: class {
  func updatePredicate(_ predicate: NSPredicate)
}

class FilterViewController: UIViewController {
  
  let dataSource = MapRegionUtility().countryTableViewDataSource()
  
  @IBOutlet weak var closeButton: UIBarButtonItem!
  @IBOutlet weak var tableView: UITableView!
  
  weak var delegate: FilterViewControllerDelegate?
  
  private let mapRegionUtility = MapRegionUtility()
  // TODO: Add text search
  private let mapPredicate = MapPredicate()
  // TODO: Finish configuring this
  
  var selectedCountries: [CountryData] = [] {
    didSet {
      print(selectedCountries.map{$0.name})
      let boundingBox = mapRegionUtility.boundingBox(from: selectedCountries)
      if let boundingBox = boundingBox {
        mapPredicate.setLatitude(minLat: boundingBox.min.latitude,
                                 maxLat: boundingBox.max.latitude)
        mapPredicate.setLongitude(minLong: boundingBox.min.longitude,
                                  maxLong: boundingBox.max.longitude)
      }
    }
  }
  
  // MARK: Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    delegate?.updatePredicate(mapPredicate.predicate)
  }
  
  // MARK: IBActions
  
  @IBAction func closeButtonAction(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: UITableViewDelegate methods

extension FilterViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    tableView.deselectRow(at: indexPath, animated: true)
    let countryAtIndexPath = dataSource[indexPath.section].countries[indexPath.row]

    if let cell = tableView.cellForRow(at: indexPath) {
      if selectedCountries.contains(countryAtIndexPath) {
        cell.accessoryType = .none
        let indexPathOfElement = selectedCountries.index(of: countryAtIndexPath)
        guard let index = indexPathOfElement else { return }
        selectedCountries.remove(at: index)
      } else {
        cell.accessoryType = .checkmark
        selectedCountries.append(countryAtIndexPath)
      }
    }
  }
}

// MARK: UITableViewDataSource methods

extension FilterViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 56
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = FilterHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
    headerView.sectionTitle.text = dataSource[section].region
    headerView.toggleButton.tag = section
    headerView.toggleButton.addTarget(self, action: #selector(handle(headerButton:)), for: .touchUpInside)
    return headerView
  }
  
  @objc func handle(headerButton: UIButton) {
    let section = headerButton.tag
    
    // TODO: close other expanded sections
    
    var indexPaths: [IndexPath] = []
    for row in dataSource[section].countries.indices {
      let indexPath = IndexPath(row: row, section: section)
      indexPaths.append(indexPath)
    }
    
    let isExpanded = dataSource[section].isExpanded
    dataSource[section].isExpanded = !isExpanded
    
    if isExpanded {
      tableView.deleteRows(at: indexPaths, with: .fade)
    } else {
      tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if dataSource[section].isExpanded {
      return dataSource[section].countries.count
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let countryDataAtIndexPath = dataSource[indexPath.section].countries[indexPath.row]
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = dataSource[indexPath.section].countries[indexPath.row].name
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.lineBreakMode = .byWordWrapping
    cell.detailTextLabel?.text = dataSource[indexPath.section].countries[indexPath.row].intermediateRegion

    if selectedCountries.contains(countryDataAtIndexPath) {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return dataSource.count
  }
  
  
}
