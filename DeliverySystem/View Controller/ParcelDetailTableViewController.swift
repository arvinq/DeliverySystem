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
    
    // determins if the datePicker is hidden or not
    var isStatusChangedDatePickerHidden: Bool = true
    var isDeliveryDatePickerHidden: Bool = true
    
    // indexPaths to easily access certain rows in table
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
    
    /**
     Configure the parcel status and the text in status' label
     - Parameter status: status to be used
     */
    func configureCurrentStatus(with status: Parcel.Status) {
        parcelStatus = status
        
        let title = Parcel.titleForStatus(status)
        statusLabel.text = title
    }
    
    /// configure the properties of the status change date.
    func configureInitialDate() {
        
       statusChangedDatePicker.date = Date()
       statusChangedDatePicker.minimumDate = Date()
        
        configureStatusDateViews()
    }
    
    /**
     update the form using the parcel passed.
     - Parameter parcel: contains the details to update the form
     */
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
    
    /// views whose state should be configured depending on the status and on edit/add mode
    func updateViewState() {
        let recipientText = recipientNameTextField.text ?? ""
        let addressText = recipientAddressTextField.text ?? ""
        let trackNoText = trackingNumberTextField.text ?? ""
        let deliveryDateText = deliveryDateLabel.text ?? ""
        
        
        /// configuring state based on parcel status
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
        
        
        /// configuring state in terms of user action
        if let _ = parcelToEdit {
            deleteButton.isEnabled = true
        } else {
            deleteButton.isEnabled = false
        }
    }
    
    
    // separated both status date and delivery date updates to properly
    // listen to actions triggered on each of its own date picker
    
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
        
        //for rows which has the date picker, height is determined by state of date pickers
        //whether it is hidden, or not.
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
        
        //selecting a particular cell changes state and properties of date picker.
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
    /// this is for when a textfield's value has changed. Editing Change event
    @IBAction func textEditingChange(_ sender: Any) {
        updateViewState()
    }
    
    /// generate tracking number and assign it to trackingNumber field
    @IBAction func generateButtonTapped(_ sender: Any) {
        let randomTrackingNumber = Parcel.generateTrackingNumber()
        trackingNumberTextField.text = randomTrackingNumber
        updateViewState()
    }
    
    /// save the parcel based on the control's values
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
        
        /// calls the appropriate delegate method
        if isEditMode {
            parcelDetailDelegate?.parcelDetailTableViewController(self, didFinishEditing: parcel)
        } else {
            parcelDetailDelegate?.parcelDetailTableViewController(self, didFinishAdding: parcel)
        }
        
    }
    
    /// called when trash can is tapped. calls willDelete delegate method
    @IBAction func deleteButtonTapped(_ sender: Any) {
        guard let parcel = parcelToEdit else { return }
        parcelDetailDelegate?.parcelDetailTableViewController(self, willDelete: parcel)
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        parcelDetailDelegate?.parcelDetailTableViewControllerDidCancel(self)
    }
    
    /// when status is changed
    @IBAction func statusDatePickerValueChanged(_ sender: Any) {
        configureStatusDateViews()
    }
    
    /// state is needed to be updated because changing delivery constitutes a button state configuration
    @IBAction func deliveryDatePickerValueChanged(_ sender: Any) {
        configureDeliveryDateViews()
        updateViewState()
    }
    
    /// this is for changing the status of the parcel.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PropertyKeys.selectStatusSegue {
            guard let destinationVC = segue.destination as? ParcelStatusTableViewController,
                  let parcel = parcelToEdit else { return }
            
            destinationVC.savedParcelStatus = parcel.status
            destinationVC.parcelStatus = parcelStatus
            destinationVC.parcelStatusDelegate = self
        }
    }
    
    /// check if segue should be performed or not. If it is in edit mode, then we perform segue.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier == PropertyKeys.selectStatusSegue,
              let _ = parcelToEdit else { return false }

        return true
    }
}

//MARK: - EXTENSIONS
extension ParcelDetailTableViewController: UITextFieldDelegate {
    
    /// resigning firstResponder or closing keyboard when return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /*   we are going to use textEditingDidChange since we require saveButton state changes
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
    /// separated the keyboard additions.
    
    /// adding observers for when a keyboard will show or not.
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(ParcelDetailTableViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ParcelDetailTableViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /**
     modifies the tableView's content insets and scroll indicator inset whenever the keyboard is shown on screen
     */
    @objc func keyboardWillShow(_ notification: Notification) {
        //get the keyboardFrameEndInfo from userInfo.
        guard let notificationUserInfo = notification.userInfo,
              let keyboardFrameRect = notificationUserInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
              else { return }
        
        let keyboardRect = keyboardFrameRect.cgRectValue //from NSValue (kfr) to CGRect to get the height
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.height, right: 0)
        
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
        
        // if notes is first responder, then when we show keyboard, we scroll to keyboard's indexPath
        if notesTextView.isFirstResponder {
            tableView.scrollToRow(at: notesTextViewIndexPath, at: .top, animated: true)
        }
        
    }
    
    ///once keyboard has hidden, return back to default content insets.
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInset = UIEdgeInsets.zero
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
}

extension ParcelDetailTableViewController: ParcelStatusTableViewControllerDelegate {
    /// the delegate method called when a status has been selected
    func parcelStatusTableViewController(_ controller: ParcelStatusTableViewController, didSelect status: Parcel.Status) {
        guard let parcel = parcelToEdit else { return }
        
        configureCurrentStatus(with: status)
        
        if status != parcel.status { //if it's a new status, then we change the status changed date.
            configureInitialDate()
        }
        
        navigationController?.popViewController(animated: true)
    }
}

extension UITextView {
    
    /// adding the done button on the keyboard. This shows Notes is first responder.
    func addDoneButton() {
        let keyboardToolbar = UIToolbar() //adds a toolbar at the top of the keyboard.
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //blank space
        //bar button added to toolbar that resigns the view's first responder status. (endEditing)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(UIView.endEditing(_:)))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.inputAccessoryView = keyboardToolbar //line that adds this toolbar when notes view is the first responder.
    }
    
}
