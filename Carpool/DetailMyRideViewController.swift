//
//  DetailMyRideViewController.swift
//  ComeUp
//
//  Created by Eva on 21.05.16.
//  Copyright © 2016 Caroline. All rights reserved.
//

import UIKit
import MapKit
import GeoFire

class DetailMyRideViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var detailData: NSDictionary = NSDictionary()
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var takenSeatsLabel: UILabel!
    
    @IBOutlet weak var userTabel: UITableView!
    
    var userList:NSArray = NSArray()
    
    var route: Route = Route()
    var routeID: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        route = self.initializeWithDictionary(detailData)
        self.loadUserList()
        print("DETAIL VIEW ACHTUNG ACHTUNG")
        print("\(route.start.title) \(route.start.coordinate)")
        print("\(route.destination.title) \(route.destination.coordinate)")
        //        while(route.start.title == nil){}
        //        while(route.destination.title == nil){}
        self.userTabel.dataSource = self
        self.userTabel.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadUserList()
    }
    
    func loadUserList(){
        print("LOAD USER LIST")
        FDataManager.dataService.CREATED_ROUTES_REF.childByAppendingPath("\(routeID)/registrated_user").observeEventType(.Value, withBlock: {
            snap in
            print(snap.value)
            if let data = snap.value as? NSArray{
                print("LOAD REGISTRATED USER FORM DATABASE")
                print(data)
                self.userList = data
                self.userTabel.reloadData()
            }
            }
        
        )
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    func initializeWithDictionary(data: NSDictionary) -> Route{
        let geoCoder = CLGeocoder()
        let r = Route()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        r.date = formatter.dateFromString(data["date"] as! String!)!
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.stringFromDate(r.date)
        
        r.price = data["price"] as! Int!
        r.seats = data["seats"] as! Int!
        r.taken = data["taken"] as! Int!
        
        r.user = data["uid"] as! String!
        
        self.startLabel.text = self.detailData["start"] as! String!
        self.destinationLabel.text = self.detailData["destination"] as! String!
        
        self.dateLabel.text = self.detailData["date"] as! String!
        self.priceLabel.text = "\(self.detailData["price"] as! Int!) €"
        self.takenSeatsLabel.text = "\(self.detailData["taken"] as! Int!)/\(self.detailData["seats"] as! Int!)"
        
        print(dateStr)
        let geoFireStart = GeoFire(firebaseRef: FDataManager.dataService.BASE_REF.childByAppendingPath("dates").childByAppendingPath(dateStr).childByAppendingPath("startLocation"))
        let geoFireDest = GeoFire(firebaseRef: FDataManager.dataService.BASE_REF.childByAppendingPath("dates").childByAppendingPath(dateStr).childByAppendingPath("destinationLocation"))
        
        geoFireStart.getLocationForKey(data["start"] as! String!, withCallback: { (location, error) in
            if (error != nil) {
                print("An error occurred getting the location for \"\(data["start"] as! String!)\": \(error.localizedDescription)")
            } else if (location != nil) {
                print("Location for \"\(data["start"] as! String!)\" is [\(location.coordinate.latitude), \(location.coordinate.longitude)]")
                
                geoCoder.reverseGeocodeLocation(location)
                    {
                        (placemarks, error) -> Void in
                        
                        let placeArray = placemarks as [CLPlacemark]!
                        
                        // Place details
                        var placeMark: CLPlacemark!
                        placeMark = placeArray?[0]
                        
                        r.start = MKPointAnnotation()
                        
                        r.start.coordinate = location.coordinate
                        print(r.start.title)
                        r.start.title = data["start"] as! String!//placeMark.name
                        print(r.start.title)
                        if let city = placeMark.locality,
                            let state = placeMark.administrativeArea {
                                r.start.subtitle = "\(city) \(state)"
                        }
                        
                        geoFireDest.getLocationForKey(data["destination"] as! String!, withCallback: { (location, error) in
                            if (error != nil) {
                                print("An error occurred getting the location for \"\(data["destination"] as! String!)\": \(error.localizedDescription)")
                            } else if (location != nil) {
                                print("Location for \"\(data["destination"] as! String!)\" is [\(location.coordinate.latitude), \(location.coordinate.longitude)]")
                                
                                geoCoder.reverseGeocodeLocation(location)
                                    {
                                        (placemarks, error) -> Void in
                                        
                                        let placeArray = placemarks as [CLPlacemark]!
                                        
                                        // Place details
                                        var placeMark: CLPlacemark!
                                        placeMark = placeArray?[0]
                                        
                                        r.destination = MKPointAnnotation()
                                        
                                        r.destination.coordinate = location.coordinate
                                        r.destination.title = data["destination"] as! String! // placeMark.name
                                        if let city = placeMark.locality,
                                            let state = placeMark.administrativeArea {
                                                r.destination.subtitle = "\(city) \(state)"
                                        }
                                        if(r.start.title != nil){
                                            print("DETAIL VIEW ACHTUNG ACHTUNG - DESTINATIONS")
                                            print("\(r.start.title) \(r.start.coordinate)")
                                            print("\(r.destination.title) \(r.destination.coordinate)")
                                            
                                            self.mapView.addAnnotation(r.start)
                                            self.mapView.addAnnotation(r.destination)
                                            
                                            var span = MKCoordinateSpan()
                                            span.latitudeDelta = abs(r.start.coordinate.latitude - r.destination.coordinate.latitude) + 0.5
                                            span.longitudeDelta = abs(r.start.coordinate.longitude - r.destination.coordinate.longitude) + 0.5
                                            var locationCenter = CLLocationCoordinate2D()
                                            locationCenter.latitude = (r.start.coordinate.latitude + r.destination.coordinate.latitude) / 2;
                                            locationCenter.longitude = (r.start.coordinate.longitude + r.destination.coordinate.longitude) / 2;
                                            
                                            let region = MKCoordinateRegionMake(locationCenter, span);
                                            
                                            self.mapView.setRegion(region, animated: true)
                                        }
                                }
                            }
                        })
                }
            }
        })
    
    //        self.reservedUser = (data["go_with"] as? [String]!)!
    return r
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.userList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("registeredUser", forIndexPath: indexPath)
//        let keys:NSArray = userList.allKeys
//        let key = keys[indexPath.row]
        print("\(userList[indexPath.row] as? String)")
        if let name = userList[indexPath.row] as? String {
            print(name)
             cell.textLabel!.text = name
        }
//        cell.textLabel!.text = userList[indexPath.row] as? String
        return cell
    }

}
