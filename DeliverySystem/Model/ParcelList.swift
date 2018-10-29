//
//  ParcelList.swift
//  DeliverySystem
//
//  Created by Arvin Quiliza on 10/20/18.
//  Copyright © 2018 arvnq. All rights reserved.
//

import Foundation

class ParcelList: Codable {
    
    var newParcelList: [Parcel] = []
    var dispatchedParcelList: [Parcel] = []
    var forPickupParcelList: [Parcel] = []
    var deliveredParcelList: [Parcel] = []
    
    init() {
        let newSampleParcel = Parcel()
        newSampleParcel.status = .new
        newSampleParcel.statusChangedDate = Date()
        newSampleParcel.recipientName = "John Snow"
        newSampleParcel.deliveryAddress = "Castle Black"
        newSampleParcel.notes = "The White Wolf"
    
        let dispatchedSampleParcel = Parcel()
        dispatchedSampleParcel.status = .dispatched
        dispatchedSampleParcel.statusChangedDate = Date()
        dispatchedSampleParcel.recipientName = "Daenerys Targaryen"
        dispatchedSampleParcel.deliveryAddress = "Dragonstone"
        dispatchedSampleParcel.notes = "The Mother of Dragons"
        dispatchedSampleParcel.trackingNumber = "F2J24"
        dispatchedSampleParcel.deliveryDate = Date()
        
        let pickupSampleParcel = Parcel()
        pickupSampleParcel.status = .forPickup
        pickupSampleParcel.statusChangedDate = Date()
        pickupSampleParcel.recipientName = "Tyrion Lannister"
        pickupSampleParcel.deliveryAddress = "Casterly Rock"
        pickupSampleParcel.notes = "The Little Lion"
        pickupSampleParcel.trackingNumber = "AGQH6"
        pickupSampleParcel.deliveryDate = Date()
        
        let deliveredSampleParcel = Parcel()
        deliveredSampleParcel.status = .delivered
        deliveredSampleParcel.statusChangedDate = Date()
        deliveredSampleParcel.recipientName = "Tormund Giantsbane"
        deliveredSampleParcel.deliveryAddress = "Beyond the wall"
        deliveredSampleParcel.notes = "Free Folk"
        deliveredSampleParcel.trackingNumber = "V55DI"
        deliveredSampleParcel.deliveryDate = Date()
        
        
        addDelivery(newSampleParcel, inStatus: newSampleParcel.status)
        addDelivery(dispatchedSampleParcel, inStatus: dispatchedSampleParcel.status)
        addDelivery(pickupSampleParcel, inStatus: pickupSampleParcel.status)
        addDelivery(deliveredSampleParcel, inStatus: deliveredSampleParcel.status)
        
    }
    
    
    func showParcels(forStatus status: Parcel.Status) -> [Parcel] {
        switch status {
            case .new: return newParcelList
            case .dispatched: return dispatchedParcelList
            case .forPickup: return forPickupParcelList
            case .delivered: return deliveredParcelList
        }
    }
    
    func newParcel() -> Parcel {
        let parcel = Parcel()
        
        addDelivery(parcel, inStatus: parcel.status)
        return parcel
    }
    
    
    func addDelivery (_ parcel: Parcel, inStatus parcelStatus: Parcel.Status, at index: Int = -1) {
        switch parcelStatus {
            case .new:
                if index < 0 { newParcelList.append(parcel) }
                else { newParcelList.insert(parcel, at: index) }
            case .dispatched:
                if index < 0 { dispatchedParcelList.append(parcel) }
                else { dispatchedParcelList.insert(parcel, at: index) }
            case .forPickup:
                if index < 0 { forPickupParcelList.append(parcel) }
                else { forPickupParcelList.insert(parcel, at: index) }
            case .delivered:
                if index < 0 { deliveredParcelList.append(parcel) }
                else { deliveredParcelList.insert(parcel, at: index) }
        }
    }
    
    func deleteDelivery (_ parcel: Parcel, inStatus parcelStatus: Parcel.Status, at index: Int) {
        switch parcelStatus {
            case .new: newParcelList.remove(at: index)
            case .dispatched: dispatchedParcelList.remove(at: index)
            case .forPickup: forPickupParcelList.remove(at: index)
            case .delivered: deliveredParcelList.remove(at: index)
        }
    }
    
    func changeDelivery (_ parcel: Parcel, fromSrcStatus srcStatus: Parcel.Status, atSrcIndex srcIndex: Int,
                         toDestStatus destStatus: Parcel.Status, atDestIndex destIndex: Int) {
        
        deleteDelivery(parcel, inStatus: srcStatus, at: srcIndex)
        addDelivery(parcel, inStatus: destStatus, at: destIndex)
    }
    
    
    static let DocumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveUrl = DocumentDirectory.appendingPathComponent(PropertyKeys.pathComponent)
        .appendingPathExtension(PropertyKeys.pathExtension)
    
    static func saveParcelsToFile(parcels: ParcelList) {
        let pListEncoder = PropertyListEncoder()
        let parcelsData = try? pListEncoder.encode(parcels)
        
        try? parcelsData?.write(to: ArchiveUrl, options: .noFileProtection)
    }
    
    static func loadParcelsFromFile() -> ParcelList? {
        let groupedParcels: ParcelList?
        
        let pListDecoder = PropertyListDecoder()
        
        guard let parcelsData = try? Data.init(contentsOf: ArchiveUrl),
            let decodedParcels = try? pListDecoder.decode(ParcelList.self, from: parcelsData)
            else { return nil }
        
        groupedParcels = decodedParcels
        
        return groupedParcels
    }
    
}
