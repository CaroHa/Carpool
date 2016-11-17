//
//  MyRidesTableViewController.swift
//  Carpool
//
//  Created by Eva on 05.05.16.
//  Copyright © 2016 Caroline. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI


class MyRidesTableViewController: UITableViewController {
    
    var dataSource: FirebaseTableViewDataSource!
    var data: NSMutableDictionary = NSMutableDictionary()
    var detailData: NSDictionary = NSDictionary()
    var routeID: String = String()
    var indicator: UIActivityIndicatorView!
    var created = false
    var selected = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        FDataManager.dataService.CREATED_ROUTES_REF.queryOrderedByChild("date").observeEventType(.Value, withBlock: { snap in
//            self.data["Created Routes"] = snap.value as! NSDictionary
//            
//            print("Snapshot value: \(snap.value)")
//            self.tableView.reloadData()
//        })
        
        self.tableView.dataSource = self
        self.tableView.delegate = self

    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.indicator.center = self.tableView.center
        view.addSubview(self.indicator)
        self.indicator.startAnimating()
        self.selected = false
        self.created = false
        
        FDataManager.dataService.CREATED_ROUTES_REF.queryOrderedByChild("date").observeEventType(.Value, withBlock: { snap in
            if let ownRoutes = snap.value as? NSDictionary{
//            print("Snapshot value: \(snap.value)")
                self.data["Created Routes"] = ownRoutes
                if self.selected{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        self.indicator.stopAnimating()
                    }
                } else {
                    self.created = true
                }
            } else {
                if self.selected{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        self.indicator.stopAnimating()
                    }
                } else{
                    self.created = true
                }
            }

        
        })
        FDataManager.dataService.SELECTED_ROUTES_REF.queryOrderedByChild("date").observeEventType(.Value, withBlock: { snap in
            if let selectedRoutes = snap.value as? NSDictionary{
                self.data["Selected Routes"] = selectedRoutes
                if self.created{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        self.indicator.stopAnimating()
                    }
                } else{
                    self.selected = true
                }
            } else {
                if self.created{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        self.indicator.stopAnimating()
                    }
                } else{
                    self.selected = true
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
        return self.data.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        let key:NSArray = self.data.allKeys
        let k = key.objectAtIndex(section)
        let sectionData = self.data.objectForKey(k)
        return (sectionData?.count)!
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keys:NSArray = self.data.allKeys
        let sec = keys.objectAtIndex(section)
        return sec as? String
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("offeredRideCell", forIndexPath: indexPath) as! OfferedRideTableViewCell

        let keys:NSArray = self.data.allKeys
        let sec = keys.objectAtIndex(indexPath.section)
        if let sectionData = self.data.objectForKey(sec){
            let secKeys:NSArray = sectionData.allKeys
            let secK = secKeys.objectAtIndex(indexPath.row)
            if let obj = sectionData.objectForKey(secK){
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
                
                print(sec)
                if sec.isEqualToString("Created Routes"){
                    if let _ = obj["taken"] as? Int!{
                    cell.seatsPriceLabel.text = "\(obj["taken"] as! Int!)/\(obj["seats"] as! Int!)"
                    cell.usernameLabel.text = "Taken Seats: "
                    }
                } else if sec.isEqualToString("Selected Routes"){
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
            }
        }

        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(self.data)
        let keys:NSArray = self.data.allKeys
        let sec = keys.objectAtIndex(indexPath.section)
            if let sectionData = self.data.objectForKey(sec){
                let secKeys:NSArray = sectionData.allKeys
                let secK = secKeys.objectAtIndex(indexPath.row)
                if let obj = sectionData.objectForKey(secK){
                    self.detailData = obj as! NSDictionary
                    self.routeID = secK as! String
                }
            }
            
//            let destController = self.storyboard?.instantiateViewControllerWithIdentifier("MyRides")
//            self.navigationController!.pushViewController(destController!, animated: true)
        if sec.isEqualToString("Created Routes"){
            performSegueWithIdentifier("showOfferedRideDetail", sender: self)
            
        } else if sec.isEqualToString("Selected Routes"){
            performSegueWithIdentifier("showSelectedRideDetail", sender: self)
        }
        //TODO: selected Routes Detail!!
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(self.detailData)
        print(self.routeID)
        if segue.identifier == "showOfferedRideDetail" {
            let secondViewController = segue.destinationViewController as! DetailMyRideViewController
            secondViewController.detailData = self.detailData
            secondViewController.routeID = self.routeID
        }
        else if segue.identifier == "showSelectedRideDetail" {
            let secondViewController = segue.destinationViewController as! DetailSelectedViewController
            secondViewController.detailData = self.detailData
            secondViewController.routeID = self.routeID
        }
    }

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

    @IBAction func logout(sender: AnyObject) {
        // unauth() is the logout method for the current user.
        
        FDataManager.dataService.CURRENT_USER_REF.unauth()
        
        // Remove the user's uid from storage.
        
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "uid")
        
        // Head back to Login!
        
        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("Login")
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
    }

}


