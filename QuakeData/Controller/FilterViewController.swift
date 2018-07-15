//
//  FilterViewController.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/11/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import RangeSeekSlider

// TODO: add backgrounds to sections
// TODO: Add scrollview for larger selections

protocol FilterViewControllerDelegate: class {
  func updatePredicate(_ predicate: NSPredicate)
}

class FilterViewController: UIViewController {
  
  let dataSource = MapRegionUtility().countryTableViewDataSource()
  var filteredCountries: [CountryData] = []
  
  @IBOutlet weak var searchButton: UIBarButtonItem!
  @IBOutlet weak var closeButton: UIBarButtonItem!
  
  // StackViews
  @IBOutlet weak var searchBarStack: UIStackView!
  @IBOutlet weak var sliderStack: UIStackView!
  
  @IBOutlet weak var slider: RangeSeekSlider!
  
  @IBOutlet weak var tableHeader: FilterHeaderView!
  @IBOutlet weak var tableView: UITableView!
  
  // filtering vars
  var isFiltering: Bool = false {
    didSet {
      updateFiltering(for: isFiltering)
    }
  }
  let searchController = UISearchController(searchResultsController: nil)
  weak var delegate: FilterViewControllerDelegate?
  
  private let mapRegionUtility = MapRegionUtility()
  private let mapPredicate = MapPredicate()
  
  // TODO: Add text search
  
  var selectedCountries: [CountryData] = [] {
    didSet {
      updateCountryLabel()
      let boundingBox = mapRegionUtility.boundingBox(from: selectedCountries)
      if let boundingBox = boundingBox {
        
        mapPredicate.setLatitude(minLat: boundingBox.min.latitude,
                                 maxLat: boundingBox.max.latitude)
        mapPredicate.setLongitude(minLong: boundingBox.min.longitude,
                                  maxLong: boundingBox.max.longitude)
      }
      
      tableView.beginUpdates()
      tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .automatic)
      tableView.endUpdates()
      self.view.layoutIfNeeded()
    }
  }
  
  // MARK: Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBarStack.isHidden = true
    tableHeader.clearButton.addTarget(self, action: #selector(clearButtonAction(_:)), for: .touchUpInside)
    configureSlider()
    configureTableView()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    delegate?.updatePredicate(mapPredicate.predicate)
  }
  
  // MARK: IBActions
  
  @IBAction func searchButtonAction(_ sender: UIBarButtonItem) {
    isFiltering = !isFiltering
  }
  
  
  @IBAction func closeButtonAction(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc func clearButtonAction(_ sender: UIButton) {
    selectedCountries.removeAll()
    tableView.reloadData()
    tableView.setContentOffset(.zero, animated: true)
  }
  
  // MARK: Initial Config
  
  fileprivate func configureTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }

  fileprivate func configureSlider() {
    slider.numberFormatter.numberStyle = .decimal
    slider.numberFormatter.maximumFractionDigits = 1
    slider.numberFormatter.roundingMode = .down
    slider.numberFormatter.positiveFormat = "0.0"
    slider.delegate = self
  }

  
  // MARK: Helpers
  
  func updateFiltering(for isFiltering: Bool) {
    UIView.animate(withDuration: 0.3) {
      self.searchBarStack.isHidden = isFiltering ? false : true
      self.sliderStack.isHidden = isFiltering ? true : false
    }
  } // end updateFiltering
  
  func updateCountryLabel() {
    
    var newString = ""
    
    let countryDict: [String : [CountryData]] = Dictionary(grouping: selectedCountries, by: {$0.region! })
    let countryDictKeys = countryDict.keys.sorted()
    
    countryDictKeys.forEach { key in
      newString = newString + key + ": "
      let countryNames =  (countryDict[key]?.compactMap{$0}.map{  $0.isoCode!.flag()}.compactMap{$0}.joined())! + "\n"
      
      newString = newString + countryNames
    }
    
    tableHeader.updateTextView(with: newString)
    self.view.layoutIfNeeded()
  } // end updateCountryLabel()
}

// MARK: UITableViewDelegate methods

extension FilterViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    tableView.deselectRow(at: indexPath, animated: true)
    let countryAtIndexPath = dataSource[indexPath.section].countries[indexPath.row]

    if let cell = tableView.cellForRow(at: indexPath) {
      if selectedCountries.contains(countryAtIndexPath) {
        cell.accessoryType = .none
        let indexOfElement = selectedCountries.index(of: countryAtIndexPath)
        guard let index = indexOfElement else { return }
        selectedCountries.remove(at: index)

      } else {
        cell.accessoryType = .checkmark
        selectedCountries.append(countryAtIndexPath)
      }
    }
  } // end didSelectRowAt
}

// MARK: UITableViewDataSource methods

extension FilterViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 36
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = FilterSectionHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 36))
    headerView.sectionTitle.text = dataSource[section].region
    headerView.selectAllButton.tag = section
    headerView.selectAllButton.addTarget(self, action: #selector(handle(selectButton:)), for: .touchUpInside)
    headerView.selectAllButton.isSelected = filterContains(dataSource[section].region) ? true : false
    headerView.expandButton.tag = section
    headerView.expandButton.isSelected = isExpandButtonSelected(in: section)
    headerView.expandButton.addTarget(self, action: #selector(handle(expandButton:)), for: .touchUpInside)
    return headerView
  }
  
  private func isExpandButtonSelected(in section: Int) -> Bool {
    return tableView.numberOfRows(inSection: section) > 0
  }
  
  private func filterContains(_ region: String) -> Bool {
    return selectedCountries.filter{$0.region == region}.count > 0
  }
  
  @objc func handle(selectButton: UIButton) {
    let section = selectButton.tag
    
    let sectionCountries = dataSource[section].countries
    
    if selectButton.isSelected {
      sectionCountries.forEach{ country in
        if !selectedCountries.contains(country) {
          selectedCountries.append(country)
        }
      }
    } else {
      sectionCountries.forEach{ country in
        selectedCountries = selectedCountries.filter{ $0 != country }
      }
    }
    self.view.layoutIfNeeded()
  }
  
  @objc func handle(expandButton: UIButton) {
    let section = expandButton.tag
    
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
    
    self.view.layoutIfNeeded()
  } // end handle(expandButton: UIButton)
  
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
    let flagEmoji = countryDataAtIndexPath.isoCode?.flag()
    if let flagEmoji = flagEmoji {
      cell.textLabel?.text = "\(flagEmoji) \(countryDataAtIndexPath.name)"
    } else {
      cell.textLabel?.text = countryDataAtIndexPath.name
    }
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.lineBreakMode = .byWordWrapping
    cell.detailTextLabel?.text = countryDataAtIndexPath.subRegion

    if selectedCountries.contains(countryDataAtIndexPath) {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }

    return cell
  } // end cellForRowAt
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return dataSource.count
  }
}

extension FilterViewController: RangeSeekSliderDelegate {
  func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
    let minMag = slider.selectedMinValue
    let maxMag = slider.selectedMaxValue
    mapPredicate.setMagnitude(minMag: Double(minMag), maxMag: Double(maxMag))
  }
}

// MARK: UISearchResultsUpdating

extension FilterViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    // TODO: implement
  }
}
