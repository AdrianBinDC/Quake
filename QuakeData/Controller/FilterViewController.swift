//
//  FilterViewController.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/11/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import RangeSeekSlider

// TODO: add backgrounds to sections?

protocol FilterViewControllerDelegate: class {
//  func updatePredicate(_ predicate: NSPredicate) // FIXME: take this out
  func updatePredicate(_ mapPredicate: MapPredicate)
}

class FilterViewController: UIViewController {
  
  let dataSource = MapRegionUtility().countryTableViewDataSource()
  lazy var countryList: [CountryData] = {
    return Array(dataSource.map{$0.countries}.joined())
  }()
  var filteredCountries: [CountryData] = []
  
  @IBOutlet weak var clearButton: UIBarButtonItem!
  @IBOutlet weak var closeButton: UIBarButtonItem!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var filterFooter: FilterFooter!
  
  // filtering vars
  var isFiltering: Bool {
    return searchController.isActive && !searchIsEmpty
  }
  
  let searchController = UISearchController(searchResultsController: nil)
  
  weak var delegate: FilterViewControllerDelegate?
  
  private let mapRegionUtility = MapRegionUtility()
  var mapPredicate = MapPredicate()
  
  var selectedCountries: [CountryData] = [] {
    didSet {
      updateTitle(countryCount: selectedCountries.count)
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
    updateTitle(countryCount: selectedCountries.count)
    configureTableView()
    configureSearchController()
    filterFooter.delegate = self
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mapPredicate.countries = selectedCountries
    delegate?.updatePredicate(mapPredicate)
  }
  
  // MARK: IBActions
  
  @IBAction func clearButtonAction(_ sender: UIBarButtonItem) {
    selectedCountries.removeAll()
    tableView.reloadData()
    tableView.setContentOffset(.zero, animated: true)
  }

  @IBAction func closeButtonAction(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  // MARK: Initial Config
  
  fileprivate func configureTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  fileprivate func configureSearchController() {
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Countries"
    searchController.searchBar.delegate = self
    navigationItem.searchController = searchController
    definesPresentationContext = true
  }
  
  // MARK: Helpers
  
  func updateTitle(countryCount: Int) {
    switch countryCount {
    case 0:
      navigationItem.title = "Select Countries"
    case 1:
      navigationItem.title = "One country selected"
    default:
      navigationItem.title = "\(countryCount) countries selected"
    }
  }
  
  // MARK: Search Methods
  var searchIsEmpty: Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    filteredCountries = countryList.filter({ (country: CountryData) -> Bool in
      return country.name.lowercased().contains(searchText.lowercased())
    })
    tableView.reloadData()
  }
}

// MARK: UITableViewDelegate methods

extension FilterViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let countryAtIndexPath: CountryData
    
    tableView.deselectRow(at: indexPath, animated: true)
    if isFiltering {
      countryAtIndexPath = filteredCountries[indexPath.row]
    } else {
      countryAtIndexPath = dataSource[indexPath.section].countries[indexPath.row]
    }
    
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
    if !isFiltering {
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
    
    return nil
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
      tableView.setContentOffset(.zero, animated: true)
    } else {
      tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
//    tableView.setContentOffset(.zero, animated: true)
//    self.view.layoutIfNeeded()
  } // end handle(expandButton: UIButton)
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering {
      return filteredCountries.count
    }
    
    if dataSource[section].isExpanded {
      return dataSource[section].countries.count
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let countryDataAtIndexPath: CountryData
    if isFiltering {
      countryDataAtIndexPath = filteredCountries[indexPath.row]
    } else {
      countryDataAtIndexPath = dataSource[indexPath.section].countries[indexPath.row]
    }
    
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
    if isFiltering {
      return 1
    } else {
      return dataSource.count
    }
  }
}

// MARK: FilterFooterDelegate

extension FilterViewController: FilterFooterDelegate {
  func updateMagnitude(minMag: Double, maxMag: Double) {
        mapPredicate.setMagnitude(minMag: Double(minMag), maxMag: Double(maxMag))
  }
}

// MARK: UISearchBarDelegate

extension FilterViewController: UISearchBarDelegate {
  // TODO: implement as needed
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchController.searchBar.resignFirstResponder()
    tableView.setContentOffset(.zero, animated: true)
  }
  
}

// MARK: UISearchResultsUpdating

extension FilterViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    if let searchBarText = searchController.searchBar.text {
      filterContentForSearchText(searchBarText)
    }
  }
}
