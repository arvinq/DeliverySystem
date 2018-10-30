//
//  PropertyKeys.swift
//  DeliverySystem
//
//  Created by Arvin Quiliza on 10/21/18.
//  Copyright © 2018 arvnq. All rights reserved.
//

import Foundation

struct PropertyKeys {
    static let parcelCellIdentifier = "parcelIdentifier"
    static let parcelStatusIdentifier = "parcelStatusIdentifier"
    
    static let parcelListTitle = "List of Parcels"
    static let parcelAddTitle = "Add New Parcel"
    static let parcelEditTitle = "Edit This Parcel"
    static let parcelSelectStatusTitle = "Select Parcel Status"
    
    static let newStatusTitle = "New Parcels"
    static let dispatchedStatusTitle = "Dispatched Parcels"
    static let forPickupStatusTitle = "Parcels for Pick Up"
    static let deliveredStatusTitle = "Delivered Parcels"
    
    static let addParcelSegue = "addParcelSegue"
    static let editParcelSegue = "editParcelSegue"
    static let selectStatusSegue = "selectStatusSegue"
    
    static let newParcelDetailTitle = "New Parcel"
    static let dispatchedParcelDetailTitle = "In Transit"
    static let pickupParcelDetailTitle = "Awaiting Collection"
    static let deliveredParcelDetailTitle = "Parcel Delivered"
    
    static let pathComponent = "parcel"
    static let pathExtension = "plist"
    
    static let alertCancel = "Cancel"
    static let alertStatusSelection = "Select New Parcel Status"
    static let alertDelete = "Delete"
    static let alertDeleteConfirm = "Confirm Delete"
}
