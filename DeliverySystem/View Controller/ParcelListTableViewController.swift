//
//  ParcelListTableViewController.swift
//  DeliverySystem
//
//  Created by Arvin Quiliza on 10/19/18.
//  Copyright © 2018 arvnq. All rights reserved.
//

import UIKit

class ParcelListTableViewController: UITableViewController {

    
    var parcelList: ParcelList
    var sourceStatus: Parcel.Status?
    var destinationStatus: Parcel.Status?
    
    
    required init?(coder aDecoder: NSCoder) {
        //if file is present, load from file, else run list init
        if let parcelListFromFile = ParcelList.loadParcelsFromFile() {
            parcelList = parcelListFromFile
        } else {
            parcelList = ParcelList.init()
        }
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = PropertyKeys.parcelListTitle
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //set the height dynamically
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100.0
    }

    /**
     Get the parcel status from the rawValue representation of the index passed.
     - Parameter index: Integer that usually represents the section from the tableView
     */
    func parcelStatusForIndex(_ index: Int) -> Parcel.Status?{
        return Parcel.Status(rawValue: index)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Parcel.Status.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let parcelStatus = parcelStatusForIndex(section) { //number of rows are passed per section.
            return parcelList.showParcels(forStatus: parcelStatus).count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let parcelStatus = parcelStatusForIndex(section) else { return nil }
        
            switch parcelStatus {
                case .new: return PropertyKeys.newStatusTitle
                case .dispatched: return PropertyKeys.dispatchedStatusTitle
                case .forPickup: return PropertyKeys.forPickupStatusTitle
                case .delivered: return PropertyKeys.deliveredStatusTitle
            }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.parcelCellIdentifier, for: indexPath) as? ParcelTableViewCell,
            let status = parcelStatusForIndex(indexPath.section) else { fatalError("Couldn't dequeue a cell") }
        
        let parcel = parcelList.showParcels(forStatus: status)[indexPath.row]
        
        cell.delegate = self
        cell.configureCell(usingParcel: parcel)
        
        
        return cell
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the row from the data source
            guard let parcelStatus = parcelStatusForIndex(indexPath.section) else { return }
            let parcel = parcelList.showParcels(forStatus: parcelStatus)[indexPath.row]
            
            //call the alert. if user chooses an option, call the escaping closure
            AlertView.showDeleteAlert(on: self) { choice in
                if choice == 1 { //as configured in showDeleteAlert, do this on confirm AlertAction
                    self.parcelList.deleteDelivery(parcel, inStatus: parcelStatus, at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    ParcelList.saveParcelsToFile(parcels: self.parcelList)
                }
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // MARK: - IBActions
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == PropertyKeys.addParcelSegue {
            guard let navController = segue.destination as? UINavigationController,
                  let parcelDetailTableVC = navController.topViewController as? ParcelDetailTableViewController else { return }
            
            parcelDetailTableVC.parcelDetailDelegate = self
            parcelDetailTableVC.parcelList = parcelList
            
        } else if segue.identifier == PropertyKeys.editParcelSegue {
            
            guard let parcelDetailTableVC = segue.destination as? ParcelDetailTableViewController else { return }
            
            parcelDetailTableVC.parcelDetailDelegate = self
            
            guard let tappedParcel = sender as? ParcelTableViewCell,
                  let indexPath = tableView.indexPath(for: tappedParcel),
                  let parcelStatus = parcelStatusForIndex(indexPath.section)  else { return }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            //save src variables (status and index) here before editing.
            sourceStatus = parcelStatus
            
            let parcel = parcelList.showParcels(forStatus: parcelStatus)[indexPath.row]
            parcelDetailTableVC.parcelToEdit = parcel
        }
    }
 

}

//MARK: - Extensions
extension ParcelListTableViewController: ParcelTableViewCellDelegate {
    
    /**
     Delegate method called when cell image is tapped.
     - Parameter cell: cell where the image view is in
     */
    func ParcelTableViewCell(didTappedbuttonOn cell: ParcelTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let parcelStatus = parcelStatusForIndex(indexPath.section) else { return }
    
        if parcelStatus != .new { //do no show new option
            let parcel = parcelList.showParcels(forStatus: parcelStatus)[indexPath.row]
            AlertView.showStatusSelectionAlert(on: self, parcel, with: parcelStatus)
        }
        
        tableView.reloadData()
    }
    
    /**
     Move the parcel from its previous status to status the user has selected from the alert
     - Parameter destinationStatus: status selected by the user
     - Parameter parcel: parcel object to be moved
     - Parameter statusChangedDate: indicates when the parcel's status is changed
     */
    func getStatusFromAlert(withNew destinationStatus: Parcel.Status, for parcel: Parcel, on statusChangedDate: Date) {
        let parcelStatus = parcel.status
        
        if let rowIndex = parcelList.showParcels(forStatus: parcelStatus).index(of: parcel) {
            let destinationStatusTotal = parcelList.showParcels(forStatus: destinationStatus).count
        
                parcel.status = destinationStatus
                parcel.statusChangedDate = statusChangedDate
            
                parcelList.changeDelivery(parcel, fromSrcStatus: parcelStatus, atSrcIndex: rowIndex,
                                          toDestStatus: destinationStatus, atDestIndex: destinationStatusTotal)
        
            tableView.reloadData()
        }
        ParcelList.saveParcelsToFile(parcels: parcelList)
    }
    
}


extension ParcelListTableViewController: ParcelDetailTableViewControllerDelegate {
    
    /**
     Delegate method called to update table when user has finished adding.
     - Parameter controller: object essence of ParcelDetailtableViewController
     - Parameter parcel: parcel object to be added
     */
    func parcelDetailTableViewController(_ controller: ParcelDetailTableViewController, didFinishAdding parcel: Parcel) {
        let parcelNewRowIndex = parcelList.showParcels(forStatus: .new).count - 1
        let indexPath = IndexPath(row: parcelNewRowIndex, section: Parcel.Status.new.rawValue)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        ParcelList.saveParcelsToFile(parcels: parcelList)
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    //there's an issue here. When you are trying to change a parcel from earlier status (higher on table) to later status (lower on table), its successful to do so by changing the data source and refreshing the tableView. But since we're looping, app will still find the obj in the later (destination) status. Now, when tableView.cellForRow is executed,  there's a tendency that the tableView function will return a nil and not execute saving down below.
    // the fix here is to try to have a state that when changing of the status has already been done for the first time for the particular parcel, we don't execute the same block of code again.
    func parcelDetailTableViewController(_ controller: ParcelDetailTableViewController, didFinishEditing parcel: Parcel) {
        var isParcelConfigured = false
        
        for status in Parcel.Status.allCases {
                if let parcelEditRowIndex = parcelList.showParcels(forStatus: status).index(of: parcel) {
                    if !isParcelConfigured { //check if the same parcel has already been configured. If yes. then don't configure anymore when the same parcel is found from other section
                        
                        let indexPath = IndexPath(row: parcelEditRowIndex, section: status.rawValue)
                        
                        guard let cell = tableView.cellForRow(at: indexPath) as? ParcelTableViewCell else { return }
                        
                        
                        cell.configureCell(usingParcel: parcel)
                        
                        //if the user has also changed the status, we need to move the parcel to right status in the list
                        if let sourceStatus = sourceStatus,
                            sourceStatus != parcel.status { //if there's no change in the status, then we don't move the parcel
                            
                            //the number parcel in the new status should be the destination index
                            let destIndex = parcelList.showParcels(forStatus: parcel.status).count
                            
                            
                            parcelList.changeDelivery(parcel, fromSrcStatus: sourceStatus, atSrcIndex: parcelEditRowIndex,
                                                      toDestStatus: parcel.status, atDestIndex: destIndex)
                        
                        }
                        
                        // since the parcel we're working with has already been moved, we also move the source status together with it
                        self.sourceStatus = parcel.status
                        isParcelConfigured = true
                        tableView.reloadData()
                    
                    }
            }
        }

        ParcelList.saveParcelsToFile(parcels: parcelList)
        
        navigationController?.popViewController(animated: true)
    }
    
    func parcelDetailTableViewController(_ controller: ParcelDetailTableViewController, willDelete parcel: Parcel) {
        if let parcelDeleteRowIndex = parcelList.showParcels(forStatus: parcel.status).index(of: parcel) {
            
            let indexPath = IndexPath(row: parcelDeleteRowIndex, section: parcel.status.rawValue)
            
            //shows an alert and executes the @escaping closure based on the user's choice
            AlertView.showDeleteAlert(on: controller) { choice in
                if choice == 1 {
                    self.parcelList.deleteDelivery(parcel, inStatus: parcel.status, at: parcelDeleteRowIndex)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    
                    ParcelList.saveParcelsToFile(parcels: self.parcelList)
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
        
        
        
    }
    
    
    func parcelDetailTableViewControllerDidCancel(_ controller: ParcelDetailTableViewController) {
        controller.dismiss(animated: true, completion: nil) //for add. presenting modally so the controller dismisses itself
        navigationController?.popViewController(animated: true) //for edit. show segue for when a vc is pushed and popped in a nc
    }
    
    
    
}
