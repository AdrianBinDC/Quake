//
//  QuakeDataTests.swift
//  QuakeDataTests
//
//  Created by Adrian Bolinger on 5/31/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import XCTest
@testable import CanvasQuake

extension XCTestCase {
  func createDate(from month: Int, day: Int, year: Int, hours: Int, minutes: Int, seconds: Int) -> Date {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let components = DateComponents(year: year,
                                    month: month,
                                    day: day,
                                    hour: hours,
                                    minute: minutes,
                                    second: seconds)
    return calendar.date(from: components)!
  }
}



class CanvasQuakeTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  // MARK: Test Date+Extension.swift
  func testIsSameDate() {
    let sameDay1 = createDate(from: 10, day: 01, year: 2018, hours: 10, minutes: 10, seconds: 12)
    let sameDay2 = createDate(from: 10, day: 01, year: 2018, hours: 11, minutes: 10, seconds: 23)
    
    let differentDay1 = createDate(from: 12, day: 12, year: 1940, hours: 10, minutes: 12, seconds: 13)
    let differentDay2 = createDate(from: 12, day: 13, year: 1963, hours: 1, minutes: 23, seconds: 40)
    
    // passes
    XCTAssert(sameDay1.isSameDate(sameDay2) == true, "Dates should match")
    XCTAssert(differentDay1.isSameDate(differentDay2) == false, "Dates should not match")
    
    // should fail -- it does
//    XCTAssert(sameDay1.isSameDate(sameDay2) != true, "Dates should match")
//    XCTAssert(differentDay1.isSameDate(differentDay2) != false, "Dates should not match")
  }
  
  func testIsBeforeDate() {
    let beforeDate1 = createDate(from: 09, day: 01, year: 2018, hours: 10, minutes: 10, seconds: 12)
    let beforeDate2 = createDate(from: 10, day: 01, year: 2018, hours: 11, minutes: 10, seconds: 23)
    
    let afterDate1 = createDate(from: 12, day: 13, year: 1963, hours: 1, minutes: 23, seconds: 40)
    let afterDate2 = createDate(from: 12, day: 12, year: 1940, hours: 10, minutes: 12, seconds: 13)

    // should pass
    XCTAssert(beforeDate1.isBeforeDate(beforeDate2) == true, "1st should be before 2nd")
    XCTAssert(afterDate1.isBeforeDate(afterDate2) == false, "1st should be before 2nd")

    // should fail -- it does
//    XCTAssert(beforeDate1.isBeforeDate(beforeDate2) == false, "1st should be before 2nd")
//    XCTAssert(afterDate1.isBeforeDate(afterDate2) == true, "1st should be before 2nd")
  }
  
  func testIsAfterDate() {
    let date1 = createDate(from: 11, day: 01, year: 2018, hours: 10, minutes: 10, seconds: 12)
    let date2 = createDate(from: 10, day: 01, year: 2018, hours: 11, minutes: 10, seconds: 23)
    
    let date3 = createDate(from: 12, day: 13, year: 1963, hours: 1, minutes: 23, seconds: 40)
    let date4 = createDate(from: 12, day: 13, year: 1963, hours: 10, minutes: 12, seconds: 13)
    
    let date5 = createDate(from: 01, day: 14, year: 1940, hours: 1, minutes: 23, seconds: 40)
    let date6 = createDate(from: 12, day: 13, year: 1963, hours: 10, minutes: 12, seconds: 13)

    
    // should pass
    XCTAssert(date1.isAfterDate(date2) == true, "1st should be before 2nd")
    XCTAssert(date3.isAfterDate(date4) == false, "1st should be before 2nd")
    XCTAssert(date5.isAfterDate(date6) == false, "5th should be after 6th")
    
    
    // should fail -- it does
//    XCTAssert(date1.isAfterDate(date2) == false, "1st should be before 2nd")
//    XCTAssert(date3.isAfterDate(date4) == true, "1st should be before 2nd")
//    XCTAssert(date5.isAfterDate(date6) == true, "5th should be after 6th")

  }
  
  func testDayByAddingDays() {
    let earlierDate = createDate(from: 01, day: 01, year: 2018, hours: 12, minutes: 12, seconds: 12)
    let oneDayAfter = createDate(from: 01, day: 02, year: 2018, hours: 12, minutes: 12, seconds: 12)
    
    // Should pass
    XCTAssert(earlierDate.dateByAdding(days: 1) == oneDayAfter, "Should be true")
    XCTAssert(earlierDate.dateByAdding(days: -1) != oneDayAfter, "Should be false")
  }
  
  func testStartOfDay() {
    // FIXME: Why is this failing?
    // UTC & GMT are 
    let sampleDate = createDate(from: 6, day: 7, year: 2018, hours: 12, minutes: 12, seconds: 12)
    let anotherSample = createDate(from: 1, day: 1, year: 2018, hours: 12, minutes: 12, seconds: 12)
    let sampleDayStart = createDate(from: 6, day: 7, year: 2018, hours: 0, minutes: 0, seconds: 0)
    
    XCTAssert(sampleDate.startOfDay == sampleDayStart, "Should be the start of the date")
    
    XCTAssert(anotherSample.startOfDay != sampleDayStart, "Should return false")
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}






























































