//
//  ParcelStatusTableViewController.swift
//  DeliverySystem
//
//  Created by Arvin Quiliza on 10/25/18.
//  Copyright © 2018 arvnq. All rights reserved.
//

import UIKit

protocol ParcelStatusTableViewControllerDelegate: class {
    func parcelStatusTableViewController(_ controller: ParcelStatusTableViewController, didSelect status: Parcel.Status)
}
class ParcelStatusTableViewController: UITableViewController {

    weak var parcelStatusDelegate: ParcelStatusTableViewControllerDelegate?
    var parcelStatus: Parcel.Status? //the parcel status that is currently changed (not yet saved)
    var savedParcelStatus: Parcel.Status? //the saved parcel status 
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = PropertyKeys.parcelSelectStatusTitle
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Parcel.Status.allCases.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.parcelStatusIdentifier, for: indexPath)

        let status = Parcel.Status.allCases[indexPath.row]
        cell.textLabel?.text = Parcel.titleForStatus(status)
        
        //this is when the cell is being returned. if the selected status is equal to parcel status from
        //previous vc or from tapped row.
        if status == parcelStatus {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //guard let _ = tableView.cellForRow(at: indexPath) else { return }
        //cell.accessoryType = .checkmark
        
        let status = Parcel.Status.allCases[indexPath.row]
        
        //if parcelStatus is not new, and status is new, don't allow to select
        //if parcelStatus is not new and status is not new, just allow
        //if parcelStatus is new  just select
        
        //if savedStatus is new, its ok to select anything including new
        //if savedStatus is not new, its ok to select anything except new
        
        if savedParcelStatus == .new {
            parcelStatus = status
            tableView.reloadData()
        } else if savedParcelStatus != .new {
            if status != .new {
                parcelStatus = status
                tableView.reloadData()
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let parcelStatus = parcelStatus else { return }
        parcelStatusDelegate?.parcelStatusTableViewController(self, didSelect: parcelStatus)
    }
    

}
