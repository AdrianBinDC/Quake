#  Canvas Quake.

## Endpoint
<!--I used a slightly different endpoint from the endpoint given in the instructions, so that you can retrieve truly historic earthquake data, rather than just cannned hour, day, week, and month returns. I created a custom URL constructor that takes two dates and enters them as parameters in the URL request to USGS's website. That is contained within QuakeData.-->

While I utilized the endpoints given on the URL referenced in the PDF, I also created a custom url constructor to get data by date, not just canned hour, day, week, and month information.

## Patterns
I used delegation to communicate between the data manager class and the view controllers. I created a custom webview to view details about the quake from the USGS' website. That view uses KVO to update a progress bar to know how the page load is going with the WKWebView.

## Third party libraries
### [`Alamofire`](https://github.com/Alamofire/Alamofire):
I utiliized Alamofire for networking. Additionally, I used Apple's URL constuctors and the Codable protocol to parse the JSON returns.

I enabled NSAllowsArbitraryLoads in the NSAppTransportSecurity dictionary in info.plist, but in a production app you'd certainly want to clamp down on internet access a bit.

### [`FSCalendar`](https://github.com/WenchaoD/FSCalendar)
For the QuakeDataViewController, I utilized `FSCalendar`, an Objective-C framework, It is IBDesignable, so configuration is a breeze. The only downside with it is it doesn't like to be put in other UIViews, just UIViewControllers. To get around that limitation, I created a UIView on a standalone View Controller and made the content view black with 20% alpha or so. This way, the code can be reused.

### [`WARangeSlider`](https://github.com/warchimede/RangeSlider)
I utilized WARangeSlider, which is a two-handled slider on the FilterView on the "yet-to-be-implemented" UIView class I'm creating to filter data from Core Data to update the user interface.

### Stackoverflow

I utilized StackOverflow to obtain the most recent version of [setting a timeout for Alamofire](https://stackoverflow.com/a/48869211/4475605). I also used StackOverflow to determine [how to save Core Data](https://stackoverflow.com/questions/33423824/how-save-to-coredata-in-background-thread-using-swift) on a background thread.

### Around the web
I utilized [dionc/MapKitExtensions.swift](https://gist.github.com/dionc/46f7e7ee9db7dbd7bddec56bd5418ca6) extension to compute the center from an array of `CLLocation2DCoordinates`.


### Core Data
I utilized Core Data to persist returns. When returns come back from USGS, before the data is imported into Core Data, I did a fetch request for unique identifiers that are already persisted. Then, I used Set to do a comparison between the two to determine which records should be persisted in Core Data.

I initially envisioned two view controllers utilizing a singleton class, but I encountered flaky behavior, so I refactored to a non-singleton class with a couple of initializers. One initializer takes date parameters andn another one just runs the canned USGS URLs. Prior to working on this project, I had never found it necessary to run core data on a background thread, so I finally got to use a private queue to run it on a background thread.

# Extra Credit

## Icons
I used Inkscape to create the vector icons in the app. Some of them are inspired by icons found at [Icons8](https://icons8.com). I utilized a script to create GoCanvas' logo in all the required sizes to ship an iOS app.

## ABWebView
I created a webview that displays the USGS webpage for the earthquakes. The webview utilizes KVO to monitor load progress.

# Testing Notes
Press the UISegmentedControl on the Quake tab to retrieve quake data for minutes, hours, week, and month. The calendar icon opens up a view controller that enables you to select a date to search via delegation.
