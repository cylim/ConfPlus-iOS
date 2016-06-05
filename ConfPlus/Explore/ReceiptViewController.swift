//
//  ReceiptViewController.swift
//  confDemo
//
//  Created by Matthew Boroczky on 15/03/2016.
//  Copyright © 2016 CY Lim. All rights reserved.
//

import Foundation
import UIKit

class ReceiptViewController: UIViewController {
    
	@IBAction func backToEvent(sender: AnyObject) {
		navigationController?.popToRootViewControllerAnimated(true)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        navigationController?.hidesBarsOnSwipe = true
    }
    
}