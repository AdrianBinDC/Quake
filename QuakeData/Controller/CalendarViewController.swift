//
//  CalendarViewController.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 5/31/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

/*
 
 Ideally, I'd like this to be an IBDesignable UIView class, but
 the framework I used, FSCalendar, does not like being instantiated
 in a UIView, so I created a UIViewController that makes it reusable.
 
 */

import UIKit
import FSCalendar

protocol CalendarViewControllerDelegate: class {
  func setDates(startDate: Date?, endDate: Date?)
}

class CalendarViewController: UIViewController {
  
  enum CalendarOperation {
    case select
    case deselect
  }
  
  var startDate: Date? {
    return calendarView.selectedDates.min()
  }
  
  var endDate: Date? {
    return calendarView.selectedDates.max()
  }
  
  var calendarViewShouldBeSelected: [Date] = [] {
    didSet {
      print(calendarViewShouldBeSelected.count)
    }
  }
  
  weak var delegate: CalendarViewControllerDelegate?
  
  @IBOutlet weak var calendarContainer: UIView!
  @IBOutlet weak var resetButton: UIButton!
  @IBOutlet weak var datesLabel: UILabel!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var calendarView: FSCalendar!
  
  // MARK: Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    calendarContainer.layer.cornerRadius = 10.0
    calendarContainer.clipsToBounds = true
    
    calendarView.delegate = self
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    // experimental
    if let start = self.startDate, let end = self.endDate {
      self.delegate?.setDates(startDate: start, endDate: end)
    } else if let start = self.startDate {
      self.delegate?.setDates(startDate: start, endDate: nil)
    }
  }
  
  deinit {

  }
  
  // MARK: IBActions
  @IBAction func resetButtonAction(_ sender: UIButton) {
    hapticFeedback(style: .medium)
    calendarView.selectedDates.forEach{ calendarView.deselect($0)}
    updateDateLabel()
  }
  
  @IBAction func closeButtonAction(_ sender: UIButton) {
    hapticFeedback(style: .medium)
    self.dismiss(animated: false, completion: nil)
  }
  
  // MARK: Helpers
  func updateDateLabel() {
    switch calendarView.selectedDates.count {
    case 0:
      datesLabel.text = "Pick a date"
    case 1:
      datesLabel.text = calendarView.selectedDates.min()?.asDate() ?? ""
    default:
      if let firstDate = calendarView.selectedDates.min()?.asDate(), let secondDate = calendarView.selectedDates.max()?.asDate() {
        datesLabel.text = "\(firstDate) - \(secondDate)"
      }
    }
  } // end updateDateLabel
  
  func updateSelection(_ date: Date) {
    switch calendarView.selectedDates.count {
    case 0 ... 1:
      return
    default:
      // nil addressed above
      if date.isAfterDate(calendarView.selectedDates.min()!) {
        var nextDate: Date = calendarView.selectedDates.min()!
        while nextDate < date {
          calendarView.select(nextDate)
          nextDate = nextDate.dateByAdding(days: 1)!
        }
      } else {
        var nextDate: Date = calendarView.selectedDates.max()!
        while nextDate > date {
          calendarView.select(nextDate)
          nextDate = nextDate.dateByAdding(days: -1)!
        }
      }
    }
  } // end updateSelection(date: Date)
  
  func updateDeselection(_ date: Date) {
    switch calendarView.selectedDates.count {
    case 0 ... 1:
      return
    default:
      // nil addressed above
      let datesToUncheck = calendarView.selectedDates.filter{$0 > date}
      for date in datesToUncheck {
        calendarView.deselect(date)
      }
      updateDateLabel()
    }
  } // end updateSelection(date: Date)
}

// MARK: FSCalendarDelegate
extension CalendarViewController: FSCalendarDelegate {
  
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    guard !date.isAfterDate(Date()) else { calendar.deselect(date); return }
    
    hapticFeedback(style: .light)
    
    updateDateLabel()
    
    updateSelection(date)
  }

  func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
    print("date DEselected is:", date.asDate())
    updateDateLabel()
    updateDeselection(date)
  }
}
