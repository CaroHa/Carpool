//
//  Route.swift
//  ComeUp
//
//  Created by Eva on 17.05.16.
//  Copyright © 2016 Caroline. All rights reserved.
//

import Foundation
import MapKit
import Firebase

class Route{
    
    var start: MKPointAnnotation
    var destination: MKPointAnnotation
    var date: NSDate
    var price: Int
    var seats: Int
    var taken: Int = 0
    var user: String = ""
    var reservedUser: [String] = []
    
    init(){
        self.start = MKPointAnnotation()
        self.destination = MKPointAnnotation()
        self.date = NSDate()
        self.price = 0
        self.seats = 0
    }
    
    init(start: MKPointAnnotation, destination: MKPointAnnotation, date: NSDate, price: Int, seats: Int){
        self.start = start
        self.destination = destination
        self.date = date
        self.price = price
        self.seats = seats
        print("Start: \(self.start.title) \(self.start.subtitle) \(self.start.description)")
    }
    
       
    func createDictionary() -> NSMutableDictionary{
        let data = NSMutableDictionary()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateStr = formatter.stringFromDate(self.date)
        print(dateStr)
        data["start"] = self.start.title
        data["destination"] = self.destination.title
        data["date"] = dateStr
        data["price"] = self.price
        data["seats"] = self.seats
        data["taken"] = self.taken
        data["uid"] =  self.user
        data.setValue(self.reservedUser, forKey: "registrated_user")
        
        return data
    }
    
    
    
}