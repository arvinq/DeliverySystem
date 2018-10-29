//
//  ParcelDetailTableViewController.swift
//  DeliverySystem
//
//  Created by Arvin Quiliza on 10/22/18.
//  Copyright © 2018 arvnq. All rights reserved.
//

import UIKit

//MARK:- Protocols
protocol ParcelDetailTableViewControllerDelegate: class {
    func parcelDetailTableViewControllerDidCancel(_ controller: ParcelDetailTableViewController)
    func parcelDetailTableViewController(_ controller: ParcelDetailTableViewController, didFinishAdding parcel: Parcel)
    func parcelDetailTableViewController(_ controller: ParcelDetailTableViewController, didFinishEditing parcel: Parcel)
    func parcelDetailTableViewController(_ controller: ParcelDetailTableViewController, willDelete parcel: Parcel)
}

class ParcelDetailTableViewController: UITableViewController {

    weak var parcelDetailDelegate: ParcelDetailTableViewControllerDelegate?
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var trackingNumberTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusChangedDateLabel: UILabel!
    @IBOutlet weak var statusChangedDatePicker: UIDatePicker!
    @IBOutlet weak var recipientNameTextField: UITextField!
    @IBOutlet weak var recipientAddressTextField: UITextField!
    @IBOutlet weak var deliveryDateLabel: UILabel!
    @IBOutlet weak var deliveryDatePicker: UIDatePicker!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var generateButton: UIButton!
    
    //MARK: - Instance Variables
    var parcelToEdit: Parcel?
    var parcelList: ParcelList?
    var parcelStatus: Parcel.Status?
    
    var isStatusChangedDatePickerHidden: Bool = true
    var isDeliveryDatePickerHidden: Bool = true
    var statusChangedDateIndexPath: IndexPath = IndexPath(row: 1, section: 1)
    var deliveryDateIndexPath: IndexPath = IndexPath(row: 2, section: 2)
    var notesTextViewIndexPath: IndexPath = IndexPath(row: 0, section: 3)
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackingNumberTextField.delegate = self
        recipientNameTextField.delegate = self
        recipientAddressTextField.delegate = self
        
        registerForKeyboardNotification()
        notesTextView.addDoneButton()
        
        
        if let parcel = parcelToEdit { //if there is a parcel to edit
            navigationItem.title = PropertyKeys.parcelEditTitle
            updateForm(with: parcel)
        } else { //else this is a new parcel
            navigationItem.title = PropertyKeys.parcelAddTitle
            configureCurrentStatus(with: .new)
            configureInitialDate()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.largeTitleDisplayMode = .never
        updateViewState()
        
    }
    
    //MARK: - Helper Methods
    
    func configureCurrentStatus(with status: Parcel.Status) {
        parcelStatus = status
        
        let title = Parcel.titleForStatus(status)
        statusLabel.text = title
    }
    
    func configureInitialDate() {
        
       statusChangedDatePicker.date = Date()
       statusChangedDatePicker.minimumDate = Date()
        
        configureStatusDateViews()
    }
    
    
    func updateForm(with parcel: Parcel) {
        
        trackingNumberTextField.text = parcel.trackingNumber
        recipientNameTextField.text = parcel.recipientName
        recipientAddressTextField.text = parcel.deliveryAddress
        notesTextView.text = parcel.notes
        
        statusChangedDatePicker.date = parcel.statusChangedDate
        deliveryDatePicker.date = parcel.deliveryDate
        
        configureCurrentStatus(with: parcel.status)
        configureStatusDateViews()
        configureDeliveryDateViews()
        
    }
    
    
    func updateViewState() {
        let recipientText = recipientNameTextField.text ?? ""
        let addressText = recipientAddressTextField.text ?? ""
        let trackNoText = trackingNumberTextField.text ?? ""
        let deliveryDateText = deliveryDateLabel.text ?? ""
        
        
        //configuring state in terms of parcel status
        if statusLabel.text != PropertyKeys.newParcelDetailTitle {
            saveButton.isEnabled = !recipientText.isEmpty && !addressText.isEmpty
                                    && !trackNoText.isEmpty && !deliveryDateText.isEmpty
            trackingNumberTextField.isEnabled = true
            generateButton.isEnabled = true
            deliveryDatePicker.minimumDate = Date()
            statusChangedDatePicker.minimumDate = Date()
            
        } else {
            saveButton.isEnabled = !recipientText.isEmpty && !addressText.isEmpty
            trackingNumberTextField.isEnabled = false
            generateButton.isEnabled = false
        }
        
        
        //configuring state in terms of user action
        if let _ = parcelToEdit {
            deleteButton.isEnabled = true
        } else {
            deleteButton.isEnabled = false
        }
    }
    
    
    
    func configureStatusDateViews() {
        statusChangedDateLabel.text = Parcel.detailDateFormatter.string(from: statusChangedDatePicker.date)
        
    }
    
    func configureDeliveryDateViews() {
        if statusLabel.text != PropertyKeys.newParcelDetailTitle { //if status is anything other than new
            deliveryDateLabel.text = Parcel.detailDateFormatter.string(from: deliveryDatePicker.date)
        }
    }
    
    
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let normalCellHeight = CGFloat(44.0)
        let largeCellHeight = CGFloat(200.0)
        
        switch (indexPath.section, indexPath.row) {
            
            case (statusChangedDateIndexPath.section, statusChangedDateIndexPath.row) :
                return ( isStatusChangedDatePickerHidden ? normalCellHeight : largeCellHeight)
            
            case (deliveryDateIndexPath.section, deliveryDateIndexPath.row) :
                return ( isDeliveryDatePickerHidden ? normalCellHeight : largeCellHeight)
            
            case (notesTextViewIndexPath.section, notesTextViewIndexPath.row) : return largeCellHeight
            default: return normalCellHeight
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section, indexPath.row) {
            case (statusChangedDateIndexPath.section, statusChangedDateIndexPath.row) :
                isStatusChangedDatePickerHidden = !isStatusChangedDatePickerHidden
                if !isDeliveryDatePickerHidden {
                    isDeliveryDatePickerHidden = !isDeliveryDatePickerHidden
                }
                statusChangedDateLabel.textColor = isStatusChangedDatePickerHidden ? .lightGray : tableView.tintColor

            case (deliveryDateIndexPath.section, deliveryDateIndexPath.row) :
                if statusLabel.text != PropertyKeys.newParcelDetailTitle { //if status is anything other than new, then show delivery date
                    isDeliveryDatePickerHidden = !isDeliveryDatePickerHidden
                    if !isStatusChangedDatePickerHidden {
                        isStatusChangedDatePickerHidden = !isStatusChangedDatePickerHidden
                    }
                    deliveryDateLabel.textColor = isDeliveryDatePickerHidden ? .lightGray : tableView.tintColor
                }
            default: break
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    //MARK: - IBActions
    @IBAction func textEditingChange(_ sender: Any) {
        updateViewState()
    }
    
    @IBAction func generateButtonTapped(_ sender: Any) {
        let randomTrackingNumber = Parcel.generateTrackingNumber()
        trackingNumberTextField.text = randomTrackingNumber
        updateViewState()
    }
    
    
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
      
        var isEditMode = false
        var tempParcel: Parcel?
        
        if parcelToEdit != nil {
            tempParcel = parcelToEdit
            isEditMode = true
        } else {
            tempParcel = parcelList?.newParcel()
            isEditMode = false
        }
        
      let trackingNumberText = trackingNumberTextField.text ?? ""
      let deliveryDateLabelText = deliveryDateLabel.text ?? ""
        
      guard let recipientNameText = recipientNameTextField.text,
            let recipientAddressText = recipientAddressTextField.text,
            let statusChangedDateLabelText = statusChangedDateLabel.text,
            let parcelStatus = parcelStatus,
            let parcel = tempParcel else { return }
        
        parcel.trackingNumber = trackingNumberText
        parcel.recipientName = recipientNameText
        parcel.deliveryAddress = recipientAddressText
        parcel.notes = notesTextView.text
        parcel.statusChangedDate = Parcel.detailDateFormatter.date(from: statusChangedDateLabelText)!
        
        if !deliveryDateLabelText.isEmpty {
            parcel.deliveryDate = Parcel.detailDateFormatter.date(from: deliveryDateLabelText)!
        }
        
        parcel.status = parcelStatus
        
        
        if isEditMode {
            parcelDetailDelegate?.parcelDetailTableViewController(self, didFinishEditing: parcel)
        } else {
            parcelDetailDelegate?.parcelDetailTableViewController(self, didFinishAdding: parcel)
        }
        
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        guard let parcel = parcelToEdit else { return }
        parcelDetailDelegate?.parcelDetailTableViewController(self, willDelete: parcel)
    }
    
    
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        parcelDetailDelegate?.parcelDetailTableViewControllerDidCancel(self)
    }
    
    @IBAction func statusDatePickerValueChanged(_ sender: Any) {
        configureStatusDateViews()
    }
    
    @IBAction func deliveryDatePickerValueChanged(_ sender: Any) {
        configureDeliveryDateViews()
        updateViewState()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PropertyKeys.selectStatusSegue {
            guard let destinationVC = segue.destination as? ParcelStatusTableViewController,
                  let parcel = parcelToEdit else { return }
            
            destinationVC.savedParcelStatus = parcel.status
            destinationVC.parcelStatus = parcelStatus
            destinationVC.parcelStatusDelegate = self
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier == PropertyKeys.selectStatusSegue,
              let _ = parcelToEdit else { return false }

        return true
    }
    
    
}

//MARK: - EXTENSIONS

extension ParcelDetailTableViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
 
    
    
    /*   we are going to use textEditingDidChange since we require saveButton state changes
     *
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text,
              let textRange = Range(range, in: oldText),
              let nameText = recipientNameTextField.text,
              let addressText = recipientAddressTextField.text else { return false }
        
        let newText = oldText.replacingCharacters(in: textRange, with: string)
        
        if !nameText.isEmpty && !addressText.isEmpty {
            saveButton.isEnabled = !newText.isEmpty
        }
        
        return true
    }
    */
}

extension ParcelDetailTableViewController {
    
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(ParcelDetailTableViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ParcelDetailTableViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        guard let notificationUserInfo = notification.userInfo,
            let keyboardFrameRect = notificationUserInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            else { return }
        
        let keyboardRect = keyboardFrameRect.cgRectValue //from NSValue (kfr) to CGRect to get the height
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.height, right: 0)
        
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
        
        if notesTextView.isFirstResponder {
            tableView.scrollToRow(at: notesTextViewIndexPath, at: .top, animated: true)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        let contentInset = UIEdgeInsets.zero
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
        
    }
}

extension ParcelDetailTableViewController: ParcelStatusTableViewControllerDelegate {
    func parcelStatusTableViewController(_ controller: ParcelStatusTableViewController, didSelect status: Parcel.Status) {
        guard let parcel = parcelToEdit else { return }
        
        configureCurrentStatus(with: status)
        
        if status != parcel.status {
            configureInitialDate()
        }
        
        navigationController?.popViewController(animated: true)
    }
}

extension UITextView {
    
    func addDoneButton() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(UIView.endEditing(_:)))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.inputAccessoryView = keyboardToolbar
    }
}
