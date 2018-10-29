//
//  AlertView.swift
//  DeliverySystem
//
//  Created by Arvin Quiliza on 10/26/18.
//  Copyright © 2018 arvnq. All rights reserved.
//

import Foundation
import UIKit


struct AlertView {
    
    static func showBasicAlert(on controller: ParcelListTableViewController, withTitle alertTitle: String,
                               having selection: Parcel.Status.AllCases, _ parcel: Parcel, and currentStatus: Parcel.Status) {
        
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: PropertyKeys.alertCancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        for choice in selection {
            
            //should I have the user select just the next status?
            //if choice.rawValue <= currentStatus.rawValue  { continue }
            
            //or if the user have mistakenly changed the status, maybe it can go back one status up
            if choice == currentStatus || choice == .new { continue }
            
            let choiceStr = Parcel.titleForStatus(choice)
            let alertAction = UIAlertAction(title: choiceStr, style: .destructive) { action in
                executeAlert(on: controller, usingNew: choice, on: parcel)
            }
            
            alertController.addAction(alertAction)
        }
        
        controller.present(alertController, animated: true, completion: nil)
    }
    
    
    static func executeAlert(on controller: ParcelListTableViewController, usingNew status: Parcel.Status, on parcel: Parcel) {
        controller.getStatusFromAlert(withNew: status, for: parcel, on: Date())
    }
    
    static func showStatusSelectionAlert(on controller: ParcelListTableViewController, _ parcel: Parcel, with currentStatus: Parcel.Status) {
        showBasicAlert(on: controller, withTitle: PropertyKeys.alertStatusSelection,
                       having: Parcel.Status.allCases, parcel, and: currentStatus)
    }
    
    static func showDeleteAlert(on controller: UITableViewController, complete: @escaping (Int) -> () ) {
        let alertController = UIAlertController(title: "Confirm Delete", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: PropertyKeys.alertCancel, style: .cancel) { action in complete(0) }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in complete(1) }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        controller.present(alertController, animated: true, completion: nil)
    }
}