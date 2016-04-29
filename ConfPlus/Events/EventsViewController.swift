//
//  EventTableViewController.swift
//  ConfPlus
//
//  Created by CY Lim on 19/03/2016.
//  Copyright © 2016 Conf+. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class EventsViewController: UIViewController, UITableViewDelegate {
    
    var eventAttendedArray = [Event]()
    @IBOutlet var eventsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data_request()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 1
         return eventAttendedArray.count
    }
    func serverStringToDate(dateString:String) -> NSDate
    {
        //move into model class for event eventually
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        //dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        
        let d1 = dateFormatter.dateFromString(dateString)
        //print(dateStart)
        return d1!
    }
    
    func dateToFullStyleString(date:NSDate) -> String
    {
        
        let df = NSDateFormatter()
        df.dateStyle = NSDateFormatterStyle.FullStyle
        let dstring = df.stringFromDate(date)
        //print(dstring)
        return dstring
    }


    func data_request()
    {
        //coredata
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        let eventEntity = NSEntityDescription.entityForName("Event", inManagedObjectContext: context)
        
        //post request
        let paramaters = [
            "method" : "getEventsByTag",
            "tag_name" : "testTag"
        ] //at the moment the api call need event id
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let serverAdd = defaults.stringForKey("server")
        {
            Alamofire.request(.POST, serverAdd, parameters: paramaters).responseJSON {
                response in switch response.result
                {
                case .Success:
                    if let value = response.result.value
                    {
                        let json = JSON(value)
                        
                        for i in 0 ..< json["data"].count
                        {
                            let aevent = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! Event
                            aevent.name = json["data"][i]["name"].stringValue
                            //print("name: \(aevent.name)")
                            aevent.from_date = self.serverStringToDate(json["data"][i]["from_date"].stringValue)
                            //print("from date:\(aevent.from_date)")
                            aevent.to_date = self.serverStringToDate(json["data"][i]["to_date"].stringValue)
                            //print("to date:\(aevent.to_date)")
                            aevent.desc = json["data"][i]["description"].stringValue
                            //print("desc: \(aevent.desc)")
                            aevent.poster_url = json["data"][i]["poster_url"].stringValue
                            //print("poster: \(aevent.poster_url)")
                            aevent.event_id = json["data"][i]["event_id"].intValue
                            //print("id: \(aevent.event_id)")
                            
                            self.eventAttendedArray.append(aevent);
                            
                        }
                        self.eventsTableView.reloadData()
                        
                    }
                case .Failure(let error):
                    print(error)
                    //handle if there is no internet connection
                    
                }
                
            }
            
        }else {
            print("server not set in LoginViewController")
        }
        
        // Save
        //let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as! User
        // eventArray = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! [Event]
        //        user.username = "matts_test_username"
        //        user.password = "matts_test_password"
        //        user.first_name = "first_name_test"
        //        user.last_name = "last_name_test"
        //        user.email = "email_test"
        
        
        
        //        do {
        //            try context.save()
        //        } catch {
        //            fatalError("Failure to save context: \(error)")
        //        }
        
        
    }

	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let aevent = eventAttendedArray[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! EventTableViewCell

		cell.eventName.text = aevent.name
		cell.eventDate.text = dateToFullStyleString(aevent.from_date!)
		
        return cell
        
        /*
        let aevent = eventArray[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("exploreCell", forIndexPath: indexPath) as! ExploreTableViewCell
        cell.eventName.text = aevent.name
        cell.eventDate.text = dateToFullStyleString(aevent.from_date!)
        print("indexpath: \(indexPath.row)")
        return cell*/

    }
	

}
