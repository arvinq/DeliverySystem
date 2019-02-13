//
//  ParcelTableViewCell.swift
//  DeliverySystem
//
//  Created by Arvin Quiliza on 10/22/18.
//  Copyright © 2018 arvnq. All rights reserved.
//

import UIKit

/// protocol providing method that is called when button inside cell is tapped
protocol ParcelTableViewCellDelegate: class {
    func ParcelTableViewCell(didTappedbuttonOn cell: ParcelTableViewCell)
}

/// Parcel's own table view cell class
class ParcelTableViewCell: UITableViewCell {

    
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var recipientAddressLabel: UILabel!
    @IBOutlet weak var statusChangeDateLabel: UILabel!
    
    @IBOutlet weak var statusButton: StatusButton!
    
    weak var delegate: ParcelTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureCellView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    /// Initializing default cell display
    func configureCellView () {
        
        recipientNameLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        recipientAddressLabel.font = UIFont.systemFont(ofSize: 12.0)
        statusChangeDateLabel.font = .systemFont(ofSize: 12.0)
        recipientAddressLabel.textColor = .lightGray
        statusChangeDateLabel.textColor = .lightGray
        
    }
    
    /**
     Updating cell's properties with parcel information.
     - Parameter parcel: containing the properties to be displayed
     */
    func configureCell (usingParcel parcel: Parcel) {
        
        let image: UIImage?
        
        recipientNameLabel.text = parcel.recipientName
        recipientAddressLabel.text = parcel.deliveryAddress
        statusChangeDateLabel.text = Parcel.listDateFormatter.string(from: parcel.statusChangedDate)
        
        /// image on status button will be determined based on parcel's status
        switch parcel.status {
            case .new: image = UIImage(named: "new.png")
            case .dispatched: image = UIImage(named: "dispatch.png")
            case .forPickup: image = UIImage(named: "pickup.png")
            case .delivered: image = UIImage(named: "delivered.jpg")
        }
        
        statusButton.setImage(image, for: .normal)
    }
    
    /// call the delegate when status button is tapped
    @IBAction func statusButtonTapped(_ sender: Any) {
        delegate?.ParcelTableViewCell(didTappedbuttonOn: self)
    }
    
    
}

