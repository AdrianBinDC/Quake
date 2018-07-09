//
//  Structs.swift
//  QuakeData
//
/*
 Copyright © 2018 Adrian Bolinger
 Created by Adrian Bolinger on 06/01/17
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

import Foundation

// https://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php

// MARK: - Structs to extract data from USGS Earthquake JSON

struct USGSData: Codable {
  let type: String
  let metadata: Metadata
  
  /*
   bbox format
   [
   minimum longitude,
   minimum latitude,
   minimum depth,
   maximum longitude,
   maximum latitude,
   maximum depth
   ]
   */
  let bbox: [Double]?
  let features: [Features]
}

struct Metadata: Codable {
  let generated: UInt64
  let url: URL
  let title: String
  let api: String
  let count: Int
  let status: Int
}

struct Features: Codable {
  let type = "Feature"
  let properties: Properties
  let geometry: QuakeGeometry
  let id: String
}

struct Properties: Codable {
  // The magnitude for the event.
  let mag: Double?
  
  // Textual description of named geographic region near to the event. This may be a city name, or a Flinn-Engdahl Region name.
  let place: String
  
  // Time when the event occurred. Times are reported in milliseconds since the epoch ( 1970-01-01T00:00:00.000Z), and do not include leap seconds. In certain output formats, the date is formatted for readability.
  let time: TimeInterval
  
  // Time when the event was most recently updated. Times are reported in milliseconds since the epoch. In certain output formats, the date is formatted for readability.
  let updated: TimeInterval
  
  // Timezone offset from UTC in minutes at the event epicenter.
  let tz: Int?
  
  // Link to USGS Event Page for event.
  let url: String
  
  // Link to GeoJSON detail feed from a GeoJSON summary feed.
  let detail: String
  
  // The total number of felt reports submitted to the DYFI? system.
  let felt: Int16?
  
  // The maximum reported intensity for the event. Computed by DYFI. While typically reported as a roman numeral, for the purposes of this API, intensity is expected as the decimal equivalent of the roman numeral. Learn more about magnitude vs. intensity.
  let cdi: Double?
  
  // The maximum estimated instrumental intensity for the event. Computed by ShakeMap. While typically reported as a roman numeral, for the purposes of this API, intensity is expected as the decimal equivalent of the roman numeral. Learn more about magnitude vs. intensity.
  let mmi: Double?
  
  // The alert level from the PAGER earthquake impact scale.
  // https://earthquake.usgs.gov/research/pager/
  let alert: String?
  
  // Indicates whether the event has been reviewed by a human.
  let status: String
  
  // This flag is set to "1" for large events in oceanic regions and "0" otherwise. The existence or value of this flag does not indicate if a tsunami actually did or will exist. If the flag value is "1", the event will include a link to the NOAA Tsunami website for tsunami information. The USGS is not responsible for Tsunami warning; we are simply providing a link to the authoritative NOAA source.
  // See http://www.tsunami.gov/ for all current tsunami alert statuses.
  let tsunami: Int
  
  // A number describing how significant the event is. Larger numbers indicate a more significant event. This value is determined on a number of factors, including: magnitude, maximum MMI, felt reports, and estimated impact.
  // Typical Values
  // [0, 1000]
  let sig: Int16?
  
  /*
   The ID of a data contributor. Identifies the network considered to be the preferred source of information for this event.
   Typical Values
   ak, at, ci, hv, ld, mb, nc, nm, nn, pr, pt, se, us, uu, uw
   */
  let net: String?
  
  // An identifying code assigned by - and unique from - the corresponding source for the event.
  let code: String?
  
  // A comma-separated list of event ids that are associated to an event.
  let ids: String
  
  // A comma-separated list of network contributors.
  let sources: String?
  
  // A comma-separated list of product types associated to this event.
  let types: String
  
  // The total number of seismic stations used to determine earthquake location.
  let nst: Int16?
  
  // Horizontal distance from the epicenter to the nearest station (in degrees). 1 degree is approximately 111.2 kilometers. In general, the smaller this number, the more reliable is the calculated depth of the earthquake.
  let dmin: Double?
  
  /*
   The root-mean-square (RMS) travel time residual, in sec, using all weights. This parameter provides a measure of the fit of the observed arrival times to the predicted arrival times for this location. Smaller numbers reflect a better fit of the data. The value is dependent on the accuracy of the velocity model used to compute the earthquake location, the quality weights assigned to the arrival time data, and the procedure used to locate the earthquake.
   */
  let rms: Double?
  
  /*
   The largest azimuthal gap between azimuthally adjacent stations (in degrees). In general, the smaller this number, the more reliable is the calculated horizontal position of the earthquake. Earthquake locations in which the azimuthal gap exceeds 180 degrees typically have large location and depth uncertainties.
   Typical Values
   [0.0, 180.0]
   */
  let gap: Double?
  
  /*
   The method or algorithm used to calculate the preferred magnitude for the event.
   Typical Values
   “Md”, “Ml”, “Ms”, “Mw”, “Me”, “Mi”, “Mb”, “MLg”
   */
  let magType: String?
  
  // Type of seismic event.
  // Typical Values
  // “earthquake”, “quarry”
  let type: String
}

struct QuakeGeometry: Codable {
  let type = "Point"
  
  /*
   [
   longitude,
   latitude,
   depth
   ]
   */
  let coordinates: [Double]
}

// struct for Volcano placemarks
// Volcanoes.json contains the backing data for this.

struct Volcano: Codable {
  let number: String
  let volcanoName: String
  let country: String
  let region: String
  let latitude: Double
  let longitude: Double
  let elevation: Int16?
  let type: String
  let status: String
  let lastKnownEruption: String
}

// TODO: Later on, incorporate volcano eruptions
/*
 https://www.ngdc.noaa.gov/nndc/struts/results?ge_23=&le_23=&type_15=Like&query_15=&op_30=eq&v_30=&type_16=Like&query_16=&op_29=eq&v_29=&type_31=EXACT&query_31=None+Selected&le_17=&ge_18=&le_18=&ge_17=&op_20=eq&v_20=&ge_7=&le_7=&bt_24=&st_24=&ge_25=&le_25=&bt_26=&st_26=&ge_27=&le_27=&type_13=Like&query_13=&type_12=Exact&query_12=&type_11=Exact&query_11=&display_look=50&t=102557&s=50
 */
enum VolcanoLastEruption: String {
  typealias RawValue = String
  
  case unknown = "Unknown"
  case d = "D"
  case d1 = "D1"
  case d2 = "D2"
  case d3 = "D3"
  case d4 = "D4"
  case d5 = "D5"
  case d6 = "D6"
  case d7 = "D7"
  case p = "P"
  case q = "Q"
  case u = "U"
  case u1 = "U1"
  case u7 = "U7"
}
