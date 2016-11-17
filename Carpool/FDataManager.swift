//
//  FDataManager.swift
//  Carpool
//
//  Created by Eva on 02.05.16.
//  Copyright © 2016 Caroline. All rights reserved.
//

import Foundation
import Firebase
import GeoFire

class FDataManager{
    static let dataService = FDataManager()
    
    private var _BASE_REF = Firebase(url: "\(BASE_URL)")
    private var _USER_REF = Firebase(url: "\(BASE_URL)/users")
    private var _ROUTE_REF = Firebase(url: "\(BASE_URL)/routes")
    private var _DATE_REF = Firebase(url: "\(BASE_URL)/dates")
    
    private var _GEO_FIRE_REF = Firebase(url: "\(BASE_URL)/locations")
    private var _GEO_FIRE: GeoFire!
    
    
    var BASE_REF: Firebase {
        return _BASE_REF
    }
    
    var USER_REF: Firebase {
        return _USER_REF
    }
    
    var ROUTE_REF: Firebase {
        return _ROUTE_REF
    }
    
    var DATE_REF: Firebase{
        return _DATE_REF
    }
//    
    var GEO_FIRE_REF: GeoFire {
        _GEO_FIRE = GeoFire(firebaseRef: _GEO_FIRE_REF)
        return _GEO_FIRE
    }
    
    var CREATED_ROUTES_REF: Firebase{
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
        let ref = Firebase(url: "\(BASE_REF)").childByAppendingPath("users").childByAppendingPath(userID).childByAppendingPath("created_routes")
        return ref
    }
    
    var SELECTED_ROUTES_REF: Firebase{
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
        let ref = Firebase(url: "\(BASE_REF)").childByAppendingPath("users").childByAppendingPath(userID).childByAppendingPath("selected_routes")
        return ref
    }
    
    var CURRENT_USER_REF: Firebase {
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
        
        let currentUser = Firebase(url: "\(BASE_REF)").childByAppendingPath("users").childByAppendingPath(userID)
        
        return currentUser!
    }
    
    func createNewAccount(uid: String, user: Dictionary<String, String>) {
        
        USER_REF.childByAppendingPath(uid).setValue(user)
    }
    
    func createNewRoute(let routeData: Route){
        //generate Autmoatic id
        //append userid to this database
        //append to user (created routes) the route id
        //
        
        let route = routeData.createDictionary()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.stringFromDate(routeData.date)
//        let date = (route["date"])!
        let userID = (route["uid"])!
        
        let key = ROUTE_REF.childByAutoId().key
        BASE_REF.childByAppendingPath("/dates/\(date)/startLocation/\(routeData.start.title!)/routes").observeEventType(.Value, withBlock: { snap in
           
            if let routes = snap.value as? NSDictionary {
                self.createLocation(routeData.start, key: key, path: "/dates/\(date)/startLocation", routes: routes, route: key)
            } else {
                self.createLocation(routeData.start, key: key, path: "/dates/\(date)/startLocation", routes: NSDictionary(), route: key)
            }

        })
        BASE_REF.childByAppendingPath("/dates/\(date)/destinationLocation/\(routeData.destination.title!)/routes").observeEventType(.Value, withBlock: { snap in
            if let routes = snap.value as? NSDictionary {
                self.createLocation(routeData.destination, key: key, path: "/dates/\(date)/destinationLocation", routes: routes, route: key)
            } else {
                self.createLocation(routeData.destination, key: key, path: "/dates/\(date)/destinationLocation", routes: NSDictionary(), route: key)
            }
        })
    
        
        let childUpdates = ["/users/\(userID)/created_routes/\(key)": route,
            "/routes/\(key)": route]
//            "/dates/\(date)/\(key)": route]
//            "/locations/\(routeData.start.title!)/routes/\(key)" : true]
//        BASE_REF.updateChildValues(childUpdates, withCompletionBlock: { error, ref in
//            if error != nil{
//                print(error.description)
//            }
//        })
        
        BASE_REF.updateChildValues(childUpdates)
       
        //ROUTE_REF.childByAutoId().setValue(route)
        
//        ROUTE_REF.childByAppendingPath(key).setValue(route)
//        BASE_REF.childByAppendingPath("/dates/\(date)/\(key)").setValue(route)
//        CURRENT_USER_REF.childByAppendingPath("created_routes/\(key)").setValue(route)
    }
    
    func createLocation(point: MKPointAnnotation, key: String, path: String, routes: NSDictionary, route: String){

        BASE_REF.childByAppendingPath("\(path)/\(point.title!)/routes").removeAllObservers()
        let coords = point.coordinate
        let location:CLLocation = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
        print(location)
        let fireRef = Firebase(url: "\(BASE_URL)\(path)")
        let geoFire = GeoFire(firebaseRef: fireRef)
        geoFire.setLocation(location, forKey: point.title!) { (error) in
            if (error != nil) {
                print("An error occured: \(error)")
            } else {
                print("Saved location successfully!")
                
                fireRef.childByAppendingPath("\(point.title!)/routes").updateChildValues(routes as! [String : AnyObject])
                fireRef.childByAppendingPath("\(point.title!)/routes").updateChildValues([route: true])
                
            }
        }
//        let ref = _GEO_FIRE_REF.childByAppendingPath(point.title!).childByAppendingPath("routes/\(key)") //.setValue([key: true])
//        let childUpdates = ["/locations/\(point.title!)/\(key)": true]
//        GEO_FIRE_REF.setValue(true, forKey: "/locations/\(point.title!)/\(key)")
//        BASE_REF.updateChildValues(childUpdates)
//        _GEO_FIRE_REF.childByAppendingPath(point.title!).childByAppendingPath("routes").childByAppendingPath(key).setValue(true)
//        ref.updateChildValues([key: true])
    }
}