//
//  Parcel.swift
//  DeliverySystem
//
//  Created by Arvin Quiliza on 10/19/18.
//  Copyright © 2018 arvnq. All rights reserved.
//

import Foundation

class Parcel: NSObject, Codable {
    
    var recipientName: String = ""
    var deliveryAddress: String = ""
    var status: Status = .new
    var trackingNumber: String = ""
    var notes: String = ""
    var statusChangedDate: Date = Date()
    var deliveryDate: Date = Date()
    
    enum Status: Int, CaseIterable, Codable {
        case new, dispatched, forPickup, delivered
    }
    
    static let detailDateFormatter: DateFormatter = {
       let dateFormatter = DateFormatter.init()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    static let listDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    static func titleForStatus(_ status: Status) -> String {
        switch status {
            case .new: return PropertyKeys.newParcelDetailTitle
            case .dispatched: return PropertyKeys.dispatchedParcelDetailTitle
            case .forPickup: return PropertyKeys.pickupParcelDetailTitle
            case .delivered: return PropertyKeys.deliveredParcelDetailTitle
        }
    }
    
    //return a 5 digit random tracking number
    static func generateTrackingNumber() -> String{
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String( (0...4).map { _ in letters.randomElement()!  } )
    }
    
    
}


