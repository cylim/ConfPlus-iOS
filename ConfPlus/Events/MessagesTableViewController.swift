//
//  MessagesTableViewController.swift
//  confDemo
//
//  Created by Matthew Boroczky on 15/03/2016.
//  Copyright © 2016 CY Lim. All rights reserved.
//

import Foundation
import UIKit
import MPGNotification


class MessagesTableViewController: UIViewController {
    
    @IBOutlet var conversationTable: UITableView!
    
    //var usersMessages = [[Message]]()
    var userConversations = [Conversation]()
    var isDispatchEmpty:Bool = true
    var participants = [UIImage]() //[User]() //hold one user per conversation to display conversation icon
    var tempParticipants = [User]()
    var event:Event!
    let companyLogo = UIImage(named: "loo")
    
    let user = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		let email = user.stringForKey("email")
		populateNavigationBar()
        userConversations = ModelHandler().getConversation(email!)
        conversationTable.reloadData()
        
        //getVenue()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let email = user.stringForKey("email")
        
        if isDispatchEmpty {
            let group: dispatch_group_t = dispatch_group_create()
            isDispatchEmpty = false
            let notification = MPGNotification(title: "Updating", subtitle: "it might takes some time for updating.", backgroundColor: UIColor.orangeColor(), iconImage: nil)
            notification.duration = 2
            notification.show()
            
            
//            APIManager().getConversationsFromAPI(email!, group: group, isDispatchEmpty: &isDispatchEmpty){ result in
            APIManager().getConversationsByUserForEventFromAPI(email!, eventID: event.event_id!, group: group, isDispatchEmpty: &isDispatchEmpty){ result in
                dispatch_group_notify(group, dispatch_get_main_queue()) {
//                    self.isDispatchEmpty = true
                    self.userConversations = ModelHandler().getConversation(email!)

                    var mattsTempCounter = 0
                    let count = self.userConversations.count
                    for i in 0..<count
                    {
                        APIManager().getUsersForConversationFromAPI(self.userConversations[i]) {
                            result in
                            mattsTempCounter += 1
                            self.tempParticipants = ModelHandler().getUsersForConversation(self.userConversations[i]/*.conversation_id!*/)!
                            
                            let count2 = self.tempParticipants.count
                            //tmp printing
                            for k in 0..<count2
                            {
                                let u = self.tempParticipants[k]
                                print(u.email)
                            }
                            //
                            if count2 > 2
                            {
                                //append empty user
//                                let u = User()
//                                self.participants.append(u)
                                print("count>2: \(count2)")
                                self.participants.append(self.companyLogo!)
                            }else{
                                for j in 0..<count2
                                {
                                    if self.tempParticipants[j].email != email
                                    {
                                        //self.participants.append(self.tempParticipants[j])
                                        self.participants.append(self.tempParticipants[j].getImage())
                                        //self.participants[i] = self.tempParticipants[j].getImage()
//                                        print("setting participants[\(i)] to \(self.tempParticipants[j])")
                                        print("setting participants[\(i)] to temp participants \(j)")

                                    }
                                }
//                                if self.tempParticipants[0].email == email
//                                {
//                                    self.participants.append(self.tempParticipants[0])
//                                }
//                                else{
//                                    self.participants.append(self.tempParticipants[1])
//                                }
                            }
                            
                            if mattsTempCounter == count
                            {
                                let cc = self.participants.count
                                for c in 0..<cc {
                                    print(self.participants[c])
                                }
                                self.conversationTable.reloadData()
                                print("Reloaded")
                            }

                        }
                    }
                    
                    
                    //self.conversationTable.reloadData()
                    //print("Reloaded")
                    
                    let notification = MPGNotification(title: "Updated", subtitle: nil, backgroundColor: UIColor.orangeColor(), iconImage: nil)
                    notification.duration = 1
                    notification.show()
                }
            }
        }
    }
    
    func getVenue()
    {
        APIManager().getVenue(self.event){ result in
            if let eventsVenue = ModelHandler().getVenueByEvent(self.event)
            {
                APIManager().getMapForVenue(eventsVenue) { result in
                    //successfully have the venue map
                }
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath:NSIndexPath = self.conversationTable.indexPathForSelectedRow!
        let messengerVC:MessengerViewController = segue.destinationViewController as! MessengerViewController
        messengerVC.conversationID = userConversations[indexPath.row].conversation_id!
        messengerVC.senderId = user.stringForKey("email")
        messengerVC.title = userConversations[indexPath.row].name
        messengerVC.senderDisplayName = userConversations[indexPath.row].lastmsg_email
        
        //set conversation object
        messengerVC.conversation = userConversations[indexPath.row]
        self.hidesBottomBarWhenPushed = true //need to hide tab bar to show message bar at the bottom. i tried to move message bar in JSQMessagesViewController but it has some action on it that when clicked it will move back down
    }
    

	
}

extension MessagesTableViewController: UITableViewDelegate{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return userConversations.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) as! MessageTableViewCell
        let row = indexPath.row
        
        
//        cell.usersName.text = "Matthew Steven Boroczky"
//        cell.messageDescription.text = "Hey michael hows everything with project going? go.."
//        cell.messageDateLabel.text = "9:05pm"
        
        cell.usersName.text = userConversations[row].name //conversation name should be the sender
        cell.messageDescription.text = userConversations[row].lastmsg_content //lastMessage?.content
        cell.messageDateLabel.text = userConversations[row].getConversationDateAsString()
        
        let count = self.participants.count
        if count > 0
        {
            cell.profilePicture.image = self.participants[row]
        }
        
		
		return cell
	}
}


//MARK: Navigation Bar Related
extension MessagesTableViewController{
	func populateNavigationBar(){
		self.navigationController?.hidesBarsOnSwipe = true
		
		let contact = UIBarButtonItem(image: UIImage(named: "security32"), style: .Plain, target: self, action: #selector(performSecurityView))
		let location = UIBarButtonItem(image: UIImage(named: "second"), style: .Plain, target: self, action: #selector(performLocationView))
		
		let space = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: self, action: nil)
		
		let buttons = [contact, space, location]
		
		self.navigationItem.setRightBarButtonItems(buttons, animated: true)
	}
	
	func performSecurityView(){
		let storyboard : UIStoryboard = UIStoryboard(name: "EventAssistServices", bundle: nil)
		let vc : SecurityViewController = storyboard.instantiateViewControllerWithIdentifier("SecurityViewController") as! SecurityViewController
        vc.event = self.event
		
		let navigationController = UINavigationController(rootViewController: vc)
		
		self.presentViewController(navigationController, animated: true, completion: nil)
	}
	
	func performLocationView(){
		let storyboard : UIStoryboard = UIStoryboard(name: "EventAssistServices", bundle: nil)
		let vc : EventLocationViewController = storyboard.instantiateViewControllerWithIdentifier("EventLocationViewController") as! EventLocationViewController
        vc.event = self.event
		
		let navigationController = UINavigationController(rootViewController: vc)
		
		self.presentViewController(navigationController, animated: true, completion: nil)
	}
}