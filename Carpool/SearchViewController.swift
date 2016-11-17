//
//  SearchViewController.swift
//  Carpool
//
//  Created by Eva on 05.05.16.
//  Copyright © 2016 Caroline. All rights reserved.
//

import UIKit
import MapKit


class SearchViewController: UITableViewController {
    
    var resultSearchControllerFrom:UISearchController? = nil
    var resultSearchControllerTo: UISearchController? = nil
    
    var selectedPin: MKPlacemark? = nil
    
    var annotationFrom:MKPointAnnotation?
    var annotationTo:MKPointAnnotation?

    @IBOutlet weak var from: UITableViewCell!
    @IBOutlet weak var to: UITableViewCell!

    @IBOutlet weak var searchBarFrom: UISearchBar!
    @IBOutlet weak var searchBarTo: UISearchBar!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    
    @IBOutlet weak var seatsTextField: UITextField!
    var route:Route!
    

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
//        let
        from.insertSubview((resultSearchControllerFrom?.searchBar)!, aboveSubview: from)
        from.addConstraint(NSLayoutConstraint(item: from, attribute: .Leading, relatedBy: .Equal, toItem: resultSearchControllerFrom?.searchBar, attribute: .Leading, multiplier: 1, constant: 75))
        
        searchBarTo = resultSearchControllerTo!.searchBar
        searchBarTo.returnKeyType = UIReturnKeyType.Done
        searchBarTo.placeholder = "destination place"
        searchBarTo.sizeToFit()
        to.insertSubview((resultSearchControllerTo?.searchBar)!, aboveSubview: to)
        to.addConstraint(NSLayoutConstraint(item: to, attribute: .Leading, relatedBy: .Equal, toItem: resultSearchControllerTo?.searchBar, attribute: .Leading, multiplier: 1, constant: 75))
        
        resultSearchControllerFrom?.hidesNavigationBarDuringPresentation = false
        resultSearchControllerFrom?.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        resultSearchControllerTo?.hidesNavigationBarDuringPresentation = false
        resultSearchControllerTo?.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SearchInDatabase" {
            let secondViewController = segue.destinationViewController as! SearchListTableViewController
            secondViewController.searchRoute = self.route
            
        }
    }
    
    @IBAction func searchRoute(sender: AnyObject) {
        let dateString:String! = dateTextField.text
        let timeString:String! = timeTextField.text
        let seatsString:String! = seatsTextField.text
        
        if dateString != "" && timeString != "" && seatsString != "" && annotationFrom != nil && annotationTo != nil {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            let str = "\(dateString) \(timeString)"
            let date = formatter.dateFromString(str)
            
            let seats = Int(seatsString)
            
            route = Route(start: annotationFrom!, destination: annotationTo!, date: date!, price: -1 , seats: seats!)
            let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
            route.user = userID
            
            performSegueWithIdentifier("SearchInDatabase", sender: self)
            
        }

    }
        
    @IBAction func logout(sender: AnyObject) {
        // unauth() is the logout method for the current user.
        
        FDataManager.dataService.CURRENT_USER_REF.unauth()
        
        // Remove the user's uid from storage.
        
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "uid")
        
        // Head back to Login!
        
        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Login")
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

   
    
}

extension SearchViewController: HandleMapSearch {
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


