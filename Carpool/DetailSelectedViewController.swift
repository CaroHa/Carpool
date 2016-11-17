//
//  DetailSelectedViewController.swift
//  ComeUp
//
//  Created by Eva on 31.05.16.
//  Copyright © 2016 Caroline. All rights reserved.
//

import UIKit
import MapKit
import GeoFire

class DetailSelectedViewController: UIViewController {

    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var takenSeatsLabel: UILabel!
    
    @IBOutlet weak var registrationButton: UIButton!
    
    var detailData: NSDictionary = NSDictionary()
    var route: Route!
    var routeID: String = String()
    var currentUser: User = User()
    var dateStr: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        route = self.initializeWithDictionary(detailData)
        print("DETAIL VIEW ACHTUNG ACHTUNG")
        print("\(route.start.title) \(route.start.coordinate)")
        print("\(route.destination.title) \(route.destination.coordinate)")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeWithDictionary(data: NSDictionary) -> Route{
        let geoCoder = CLGeocoder()
        let r = Route()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        r.date = formatter.dateFromString(data["date"] as! String!)!
        formatter.dateFormat = "yyyy-MM-dd"
        dateStr = formatter.stringFromDate(r.date)
        
        r.price = data["price"] as! Int!
        r.seats = data["seats"] as! Int!
        r.taken = data["taken"] as! Int!
        
        r.user = data["uid"] as! String!
        
        
        FDataManager.dataService.CURRENT_USER_REF.observeEventType(.Value, withBlock: { snap in
            if let user = snap.value as? NSDictionary{
                self.currentUser.email = user["email"] as! String!
                self.currentUser.username = user["username"] as! String
                if let dic = user["selected_routes"] as? NSMutableDictionary{
                    self.currentUser.selectedRoutes = dic
                    let keys:NSArray = self.currentUser.selectedRoutes.allKeys
                    for key in keys{
                        if (key as! String) == self.routeID{
                            self.disableButton()
                        }
                    }
                }
                FDataManager.dataService.CURRENT_USER_REF.removeAllObservers()
            }
            
        })
        
        FDataManager.dataService.BASE_REF.childByAppendingPath("users/\(self.detailData["uid"] as! String!)").observeEventType(.Value, withBlock: { snap in
            if let user = snap.value as? NSDictionary{
                self.usernameLabel.text = user["username"] as! String!
            }
        })
        
        self.startLabel.text = self.detailData["start"] as! String!
        self.destinationLabel.text = self.detailData["destination"] as! String!
        
        self.dateLabel.text = self.detailData["date"] as! String!
        self.priceLabel.text = "\(self.detailData["price"] as! Int!) €"
        self.takenSeatsLabel.text = "\(self.detailData["taken"] as! Int!)/\(self.detailData["seats"] as! Int!)"
        
        if let x = data.valueForKey("registrated_user") {
            r.reservedUser = x as! [String]
        }
        
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
        
        return r
    }

    func disableButton(){
        self.registrationButton.enabled = false
        self.registrationButton.setTitle("Already registered for this route", forState: UIControlState())
        self.registrationButton.backgroundColor = UIColor.lightGrayColor()
    }
    
    @IBAction func registrateForRoute(sender: AnyObject) {
        /*
        TODO:
        -1 taken  +1
        -2 add Username to selected User
        -3 Update Route-Object (DB)
        -4 change Background-color of Button (if current user is in selected user list) -> in didLoad/willAppear !DISABLE BUTTON! !CHANGE TEXT!
        -5 add route to selectedRoutes of User(DB)
        */
//        self.route.taken += 1 //1
        FDataManager.dataService.CURRENT_USER_REF.observeEventType(.Value, withBlock: { snap in
            if let user = snap.value as? NSDictionary{
                if(self.route.reservedUser.contains(user["username"] as! String!)){
                    self.route.taken = self.route.reservedUser.count
                    let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
                    let routeData = self.route.createDictionary()
                    let childUpdates = ["/users/\(userID)/selected_routes/\(self.routeID)": routeData, //5
                        "/routes/\(self.routeID)": routeData, //3
                        "/users/\(self.route.user)/created_routes/\(self.routeID)": routeData] //3
                    FDataManager.dataService.BASE_REF.updateChildValues(childUpdates)
                    
                    self.takenSeatsLabel.text = "\(self.route.taken)/\(self.route.seats)"
                    self.disableButton()
                    FDataManager.dataService.CURRENT_USER_REF.removeAllObservers()
                } else {
                    self.route.reservedUser.append(user["username"] as! String!) //2
                    self.route.taken = self.route.reservedUser.count
                    let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
                    let routeData = self.route.createDictionary()
                    let childUpdates = ["/users/\(userID)/selected_routes/\(self.routeID)": routeData, //5
                        "/routes/\(self.routeID)": routeData, //3
                        "/users/\(self.route.user)/created_routes/\(self.routeID)": routeData] //3
                    FDataManager.dataService.BASE_REF.updateChildValues(childUpdates)
                    
                    self.takenSeatsLabel.text = "\(self.route.taken)/\(self.route.seats)"
                    self.disableButton()
                    FDataManager.dataService.CURRENT_USER_REF.removeAllObservers()
                }
                
            }
            
        })
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
