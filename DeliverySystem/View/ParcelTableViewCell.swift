//
//  ParcelTableViewCell.swift
//  DeliverySystem
//
//  Created by Arvin Quiliza on 10/22/18.
//  Copyright © 2018 arvnq. All rights reserved.
//

import UIKit

protocol ParcelTableViewCellDelegate: class {
    func ParcelTableViewCell(didTappedbuttonOn cell: ParcelTableViewCell)
}

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

    func configureCellView () {
        
        recipientNameLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        recipientAddressLabel.font = UIFont.systemFont(ofSize: 12.0)
        statusChangeDateLabel.font = .systemFont(ofSize: 12.0)
        recipientAddressLabel.textColor = .lightGray
        statusChangeDateLabel.textColor = .lightGray
        
    }
    
    func configureCell (usingParcel parcel: Parcel) {
        
        let image: UIImage?
        
        recipientNameLabel.text = parcel.recipientName
        recipientAddressLabel.text = parcel.deliveryAddress
        statusChangeDateLabel.text = Parcel.listDateFormatter.string(from: parcel.statusChangedDate)
        
        
        switch parcel.status {
            case .new: image = UIImage(named: "new.png")
            case .dispatched: image = UIImage(named: "dispatch.png")
            case .forPickup: image = UIImage(named: "pickup.png")
            case .delivered: image = UIImage(named: "delivered.jpg")
        }
        
        statusButton.setImage(image, for: .normal)
    }
    
    
    @IBAction func statusButtonTapped(_ sender: Any) {
        delegate?.ParcelTableViewCell(didTappedbuttonOn: self)
    }
    
    
}

