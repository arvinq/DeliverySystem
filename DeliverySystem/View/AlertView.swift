//
//  AlertView.swift
//  DeliverySystem
//
//  Created by Arvin Quiliza on 10/26/18.
//  Copyright © 2018 arvnq. All rights reserved.
//

import Foundation
import UIKit

/**
 Handles the alert in the application
 */
struct AlertView {
    
    /**
     This method sets up the basic alert controller, action and presents it to view
     - Parameters:
         - controller: ParcelListTableViewController
         - alertTitle: The title of the alert message
         - selection: Status' all cases. These represents the choices where user would choose from
         - parcel: the parcel where the alert is being triggered
         - currentStatus: parcel's current status
     */
    static func showBasicAlert(on controller: ParcelListTableViewController, withTitle alertTitle: String,
                               having selection: Parcel.Status.AllCases, _ parcel: Parcel, and currentStatus: Parcel.Status) {
        
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: PropertyKeys.alertCancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        for choice in selection {
            
            /// should I have the user select just the next status?
            /// if choice.rawValue <= currentStatus.rawValue  { continue }
            
            /// or if the user have mistakenly changed the status, maybe it can go back one status up
            if choice == currentStatus || choice == .new { continue }
            
            let choiceStr = Parcel.titleForStatus(choice)
            let alertAction = UIAlertAction(title: choiceStr, style: .destructive) { action in
                executeAlert(on: controller, usingNew: choice, on: parcel)
            }
            
            alertController.addAction(alertAction)
        }
        
        controller.present(alertController, animated: true, completion: nil)
    }
    
    
    /**
     This method serves as the handler method when a choice is selected from the alert
     - Parameters:
        - controller: ParcelListTableViewController
        - status: new status for the parcel chosen by the user
        - parcel: parcel being updated
     */
    static func executeAlert(on controller: ParcelListTableViewController, usingNew status: Parcel.Status, on parcel: Parcel) {
        controller.getStatusFromAlert(withNew: status, for: parcel, on: Date())
    }
    
    /**
     Calls the basic alert to show the list of status for changing parcel's status
     - Parameters:
         - controller: ParcelListTableViewController
         - currentStatus: parcel's current status
         - parcel: parcel being asked its status
     */
    static func showStatusSelectionAlert(on controller: ParcelListTableViewController, _ parcel: Parcel, with currentStatus: Parcel.Status) {
        showBasicAlert(on: controller, withTitle: PropertyKeys.alertStatusSelection,
                       having: Parcel.Status.allCases, parcel, and: currentStatus)
    }
    
    /**
     Calls an alert to confirm parcel deletion
     - Parameters:
         - controller: UITableViewController
         - complete: escaping closure to pass value and execute in calling statement
     */
    static func showDeleteAlert(on controller: UITableViewController, complete: @escaping (Int) -> () ) {
        let alertController = UIAlertController(title: PropertyKeys.alertDeleteConfirm, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: PropertyKeys.alertCancel, style: .cancel) { action in complete(0) }
        let deleteAction = UIAlertAction(title: PropertyKeys.alertDelete, style: .destructive) { (action) in complete(1) }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        controller.present(alertController, animated: true, completion: nil)
    }
}
