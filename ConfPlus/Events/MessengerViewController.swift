//
//  MessengerViewController.swift
//  ConfPlus
//
//  Created by Matthew Boroczky on 15/05/2016.
//  Copyright © 2016 Conf+. All rights reserved.
//

import Foundation
import UIKit
import MPGNotification
import JSQMessagesViewController

class MessengerViewController: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    var conversationID = ""
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("conversationid: \(conversationID)")
        setupBubbles()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // messages from someone else
        addMessage("foo", displayName: "cy", text: "Hey person!")
        // messages sent from local sender
        addMessage(senderId, displayName: "matt", text: "Yo!")
        addMessage(senderId, displayName: "matt", text: "I like turtles!")
        // animates the receiving of a new message on the view
        finishReceivingMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId { //check if message was sent by local user
            return outgoingBubbleImageView
        } else { // if not local user return incoming message
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId
        {
            
        }
        return nil
    }
    
    func addMessage(id: String, displayName:String, text: String) {
        let message = JSQMessage(senderId: id, displayName: displayName, text: text)
        messages.append(message)
    }
}

