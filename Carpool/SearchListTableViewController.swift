//
//  SearchListTableViewController.swift
//  ComeUp
//
//  Created by Eva on 27.05.16.
//  Copyright © 2016 Caroline. All rights reserved.
//

import UIKit
import MapKit
import GeoFire

class SearchListTableViewController: UITableViewController {
    
    var searchRoute: Route!
    var searchList: NSMutableDictionary = NSMutableDictionary()
    var data: NSMutableDictionary = NSMutableDictionary()
    var detailData: NSDictionary = NSDictionary()
    var routeID :String!
    
    let startResults:NSMutableDictionary = NSMutableDictionary()
    let destResults:NSMutableDictionary = NSMutableDictionary()
    
    var indicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
      
        loadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.indicator.center = self.tableView.center
        view.addSubview(self.indicator)
        self.indicator.startAnimating()
        loadData()
    }
    
    func loadData(){
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.stringFromDate(searchRoute.date)
        
        let startLoc = CLLocation(latitude: self.searchRoute.start.coordinate.latitude, longitude: self.searchRoute.start.coordinate.longitude)
        let destLoc = CLLocation(latitude: self.searchRoute.destination.coordinate.latitude, longitude: self.searchRoute.destination.coordinate.longitude)
        
        let geoFireStart = GeoFire(firebaseRef: FDataManager.dataService.BASE_REF.childByAppendingPath("dates").childByAppendingPath(date).childByAppendingPath("startLocation"))
        let startQuery = geoFireStart.queryAtLocation(startLoc, withRadius: 20.0)
        
        let geoFireDest = GeoFire(firebaseRef: FDataManager.dataService.BASE_REF.childByAppendingPath("dates").childByAppendingPath(date).childByAppendingPath("destinationLocation"))
        let destQuery = geoFireDest.queryAtLocation(destLoc, withRadius: 20.0)
        
        print("QUERY!!")
        
        startQuery.observeEventType(.KeyEntered, withBlock: { (keyStart: String!, locationStart: CLLocation!) in
            self.startResults["\(keyStart)"] = ""
            print("START")
            print(self.startResults)
            FDataManager.dataService.BASE_REF.childByAppendingPath("dates/\(date)/startLocation/\(keyStart)/routes").observeEventType(.Value, withBlock: { snap in
                if let data = snap.value as? NSDictionary{
                    self.startResults["\(keyStart)"] = ["routes" : data, "location": locationStart]
                    print(self.startResults)
                    self.reload()
                }
                
            })
        })
        destQuery.observeEventType(.KeyEntered, withBlock: { (keyDest: String!, locationDes: CLLocation!) in
            print("DEST")
            self.destResults["\(keyDest)"] = ""
            print(self.destResults)
            FDataManager.dataService.BASE_REF.childByAppendingPath("dates/\(date)/destinationLocation/\(keyDest)/routes").observeEventType(.Value, withBlock: { snap in
                if let data = snap.value as? NSDictionary{
                    self.destResults["\(keyDest)"] = ["routes" : data, "location" : locationDes]
                    print(self.destResults)
                    self.reload()
                    
                }
                
            })
        })
        startQuery.observeReadyWithBlock({
            destQuery.observeReadyWithBlock({
                self.reload()
            })
        })

    }
    
    func reload(){
        
        
        let startKeys = startResults.allKeys
        let destKeys = destResults.allKeys
        
        if(startKeys.count < 1){
            return
        }
        if destKeys.count < 1{
            return
        }
        for key in startKeys{
            if (startResults["\(key)"] as? String == ""){
                return
            }
        }
        for key in destKeys{
            if destResults["\(key)"] as? String == "" {
                return
            }
        }
        print(startResults)
        print(destResults)
        
        for keyS in startKeys{
            if let startRoutes = startResults["\(keyS)"]!.valueForKey("routes") as? NSDictionary{
                for (keyRS, valueRS) in startRoutes {
                    for keyD in destKeys{
                        if let destRoutes = destResults["\(keyD)"]!.valueForKey("routes") as? NSDictionary{
                            for(keyRD, valueRD) in destRoutes{
                                if keyRS as? String == keyRD as? String{
                                    print("HELLO WORLD")
                                    print(keyRS)
                                    self.searchList["\(keyRS)"] = valueRS
                                    self.loadDataFromList("\(keyRS)")
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func loadDataFromList(key: String){
//        for (key, value) in self.searchList{
            FDataManager.dataService.BASE_REF.childByAppendingPath("routes/\(key)").observeEventType(.Value, withBlock: { snap in
                if let value = snap.value as? NSDictionary{
                    self.searchList["\(key)"] = value
                    let seats = (value["seats"] as! Int!)
                    let taken = value["taken"] as! Int!
                    let uid =  value["uid"] as! String!
                    print("SEARCHLIST: \(key): \(value)")
                    if self.searchRoute.seats <= (seats - taken) && self.searchRoute.user !=  uid{
                        self.data["\(key)"] = value
                        print("Data LIST 2: \(key): \(value)")
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                            self.indicator.stopAnimating()
                        }
                    }
                }
            })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.data.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath) as! OfferedRideTableViewCell
        
        let keys:NSArray = self.data.allKeys
        let key = keys.objectAtIndex(indexPath.row)
        
        if let obj = self.data.objectForKey(key){
            //                print(obj)
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let str = (obj["date"])! as! String
            print(str)
            let date:NSDate = formatter.dateFromString(str)!
            
            let strFormatter = NSDateFormatter()
            strFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
            let dateString = strFormatter.stringFromDate(date)
            
            cell.dateLabel.text = "\(dateString)"
            
            cell.routeLabel.text = "\(obj["start"] as! String!) - \(obj["destination"] as! String!)"
            cell.seatsPriceLabel.text = "\(obj["price"] as! Int!) €"
            
            FDataManager.dataService.BASE_REF.childByAppendingPath("users/\(obj["uid"] as! String!)").observeEventType(.Value, withBlock: {
                snap in
                if let value = snap.value as? NSDictionary{
                    if let username = value["username"] as? String{
                         cell.usernameLabel.text = "\(username)"
                    }
                }
            })
            
           
        
        }
        
        return cell

    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let keys:NSArray = self.data.allKeys
        let key = keys.objectAtIndex(indexPath.row)
        
        if let obj = self.data.objectForKey(key){
            self.detailData = obj as! NSDictionary
            self.routeID = key as! String
        }
        
        performSegueWithIdentifier("selectedRouteDetail", sender: self)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectedRouteDetail" {
            let secondViewController = segue.destinationViewController as! DetailSelectedViewController
            secondViewController.detailData = self.detailData
            secondViewController.routeID = self.routeID
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
