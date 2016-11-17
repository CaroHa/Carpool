//
//  CreateRideTableViewController.swift
//  Carpool
//
//  Created by Eva on 05.05.16.
//  Copyright © 2016 Caroline. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch{
    func dropPinZoomIn(placemark:MKPlacemark)
}

class CreateRideTableViewController: UITableViewController {

    var resultSearchControllerFrom:UISearchController? = nil
    var resultSearchControllerTo: UISearchController? = nil
    
    @IBOutlet weak var from: UITableViewCell!
    @IBOutlet weak var to: UITableViewCell!
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedPin: MKPlacemark? = nil
    
    var annotationFrom:MKPointAnnotation?
    var annotationTo:MKPointAnnotation?
    
    @IBOutlet weak var searchBarFrom: UISearchBar!
    @IBOutlet weak var searchBarTo: UISearchBar!
    
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var time: UITextField!
    @IBOutlet weak var seatsTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    
    
    
    var fromCity: NSString!
    var toCity: NSString!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locationSearchTable1 = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        let locationSearchTable2 = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        locationSearchTable1.mapView = mapView
        locationSearchTable2.mapView = mapView
        locationSearchTable1.handleMapSearchDelegate = self
        locationSearchTable2.handleMapSearchDelegate = self
        
        resultSearchControllerFrom = UISearchController(searchResultsController: locationSearchTable1)
        resultSearchControllerFrom?.searchResultsUpdater = locationSearchTable1
        
        resultSearchControllerTo = UISearchController(searchResultsController: locationSearchTable2)
        resultSearchControllerTo?.searchResultsUpdater = locationSearchTable2
        
        searchBarFrom = resultSearchControllerFrom!.searchBar
        searchBarFrom.returnKeyType = UIReturnKeyType.Done
        searchBarFrom.placeholder = "start place"
        searchBarFrom.sizeToFit()
        from.insertSubview((resultSearchControllerFrom?.searchBar)!, aboveSubview: from)
        
        searchBarTo = resultSearchControllerTo!.searchBar
        searchBarTo.returnKeyType = UIReturnKeyType.Done
        searchBarTo.placeholder = "destination place"
        searchBarTo.sizeToFit()
        to.insertSubview((resultSearchControllerTo?.searchBar)!, aboveSubview: to)
        
        resultSearchControllerFrom?.hidesNavigationBarDuringPresentation = false
        resultSearchControllerFrom?.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        resultSearchControllerTo?.hidesNavigationBarDuringPresentation = false
        resultSearchControllerTo?.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveNewRide(sender: AnyObject) {
        let dateString:String! = dateTF.text
        let timeString:String! = time.text
        let seatsString:String! = seatsTF.text
        let priceString:String! = priceTF.text
        
       
        
        
        if dateString != "" && timeString != "" && seatsString != "" && priceString != "" && annotationFrom != nil && annotationTo != nil {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            let str = "\(dateString) \(timeString)"
            let date = formatter.dateFromString(str)
            print(date)
            print(formatter.stringFromDate(date!))
            
            let seats = Int(seatsString)
            let price = Int(priceString)
            
            let route = Route(start: annotationFrom!, destination: annotationTo!, date: date!, price: price!, seats: seats!)
            let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
            route.user = userID
            
//            let routeData = route.createDictionary()

            FDataManager.dataService.createNewRoute(route)

            let destController = self.storyboard?.instantiateViewControllerWithIdentifier("MyRides")
            self.navigationController!.pushViewController(destController!, animated: true)
        }
    }
}


extension CreateRideTableViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        if let fromCity = searchBarFrom.text{
            if (placemark.name?.rangeOfString(fromCity)) != nil{
                if annotationFrom != nil {
                    mapView.removeAnnotation(annotationFrom!)
                }
                annotationFrom = annotation
                
            }
        }
        if let toCity = searchBarTo.text{
            if (placemark.name?.rangeOfString(toCity)) != nil{
                if annotationTo != nil{
                    mapView.removeAnnotation(annotationTo!)
                }
                annotationTo = annotation
            }
        }
        
        if annotationFrom != nil && annotationTo != nil {
            var span = MKCoordinateSpan()
            span.latitudeDelta = abs(annotationFrom!.coordinate.latitude - annotationTo!.coordinate.latitude) + 0.5
            span.longitudeDelta = abs(annotationFrom!.coordinate.longitude - annotationTo!.coordinate.longitude) + 0.5
            var locationCenter = CLLocationCoordinate2D()
            locationCenter.latitude = (annotationFrom!.coordinate.latitude + annotationTo!.coordinate.latitude) / 2;
            locationCenter.longitude = (annotationFrom!.coordinate.longitude + annotationTo!.coordinate.longitude) / 2;
            
            let region = MKCoordinateRegionMake(locationCenter, span);
            
            self.mapView.setRegion(region, animated: true)
            
            
        }
        
        
        
    }
  }