//
//  EditViewController.swift
//  SearchingSorting
//
//  Created by ebsadmin on 16/07/21.
//  Copyright © 2021 droisys. All rights reserved.
//

import UIKit
import CoreData

protocol passDataBack {
    func updateRowData(updatedData: [Items])
}

class EditViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var dobPicker: UITextField!
    @IBOutlet var genderButtons: [UIButton]!
    @IBOutlet weak var aboutMe: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var labelLastName: UILabel!
    @IBOutlet weak var labelDob: UILabel!
    @IBOutlet weak var labelGender: UILabel!
    @IBOutlet weak var labelMale: UILabel!
    @IBOutlet weak var labelFemale: UILabel!
    @IBOutlet weak var labelAboutMe: UILabel!
    
    @IBOutlet weak var btnSelectImage: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    var dataPass = [Items]()        //for storing selectedRowData from FirstVC
    var delegate: passDataBack!

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let datePicker = UIDatePicker()
    var gender: String = ""
    var age:[Int]? = []

    override func viewDidLoad() {
        super.viewDidLoad()
        print("editVC viewDidLoad")
        imageView.layer.cornerRadius = imageView.frame.height/2 // For round imageView
        imageView.layer.masksToBounds = true
        showDatePicker()
        self.fName.delegate = self
        self.lName.delegate = self
        self.dobPicker.delegate = self
        
        fName.text = dataPass[0].fName
        lName.text = dataPass[0].lName
        dobPicker.text = dataPass[0].dateofbirth
        age = dataPass[0].age
        aboutMe.text = dataPass[0].aboutMe
        gender = dataPass[0].gender!
        if gender == "Male" {
            genderButtons[1].isSelected = true
        }
        else {
            genderButtons[0].isSelected = true
        }
        imageView.image = UIImage(data: dataPass[0].image!)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - getGender
    @IBAction func selectGender(_ sender: UIButton) {
        for button in genderButtons {
            button.isSelected = false
        }
        sender.isSelected = true
        gender = sender.currentTitle!
        print(gender)
    }
    
    //MARK: - Image
    @IBAction func selectImage(_ sender: UIButton) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //To select and display image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)  // to dismiss the navigator when the image has been selected.
    }
    
    //MARK: - Date
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        dobPicker.inputAccessoryView = toolbar
        dobPicker.inputView = datePicker
    }
    
    @objc func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        dobPicker.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
        age = getAgeFromDOB(date: dobPicker.text!)
        if age![0] < 16 {
            showAlert("Age should be above 16")
            dobPicker.text = ""
        } else {
            labelGender.isHidden = false
            genderButtons[0].isHidden = false
            labelMale.isHidden = false
            genderButtons[1].isHidden = false
            labelFemale.isHidden = false
            labelAboutMe.isHidden = false
            aboutMe.isHidden = false
            imageView.isHidden = false
            btnSelectImage.isHidden = false
            btnSave.isHidden = false
        }
        print(age!)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    func getAgeFromDOB(date: String) -> Array<Int> {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy/MM/dd"
        let dateOfBirth = dateFormater.date(from: date)
        let calender = Calendar.current
        let dateComponent = calender.dateComponents([.year, .month, .day], from:
            dateOfBirth!, to: Date())
        return [dateComponent.year!, dateComponent.month!, dateComponent.day!]
    }
    
    //MARK: - Save button
    @IBAction func saveClicked(_ sender: UIButton) {
        if (fName.text?.isEmpty)! {
            showAlert("Enter first name")
        }
        else if (lName.text?.isEmpty)! {
            showAlert("Enter last name")
        }
        else if (dobPicker.text?.isEmpty)! {
            showAlert("Enter D.O.B")
        }
        else if  gender.isEmpty {
            showAlert("Choose gender")
        }
        else {
            var updatedData = [Items]()
            updatedData = dataPass
            updatedData[0].fName = fName.text
            updatedData[0].lName = lName.text
            updatedData[0].dateofbirth = dobPicker.text
            updatedData[0].gender = gender
            updatedData[0].image = imageView.image?.pngData()
            updatedData[0].aboutMe = aboutMe.text
            updatedData[0].age = age
            updatedData[0].name = fName.text! + " " + lName.text!
            delegate.updateRowData(updatedData: updatedData)
            saveItems()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - Save items function
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    //MARK: - Alert function
    func showAlert(_ titleMessage: String) {
        let alert = UIAlertController(title: titleMessage, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            print("Tapped OK")
        }))
        present(alert, animated: true)
    }
    
    //MARK: - Camera function
    func showCamera() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController(title: nil, message: "Device has no camera.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            //for camera front
            // picker.cameraDevice = .front
            picker.delegate = self
            picker.allowsEditing = false
            present(picker, animated: true)
        }
    }
    //MARK: - Album function
    func showAlbum() {
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imageController, animated: true, completion: nil)
        print("Select image")
    }
}
extension EditViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        performAction(textField.tag)
        return true
    }
    func performAction(_ tag: Int) {
        switch tag {
        case 0:
            labelLastName.isHidden = false
            lName.isHidden = false
        //lName.becomeFirstResponder()
        case 1:
            labelDob.isHidden = false
            dobPicker.isHidden = false
            //dobPicker.becomeFirstResponder()
        // all other cases of Unhiding labels and text fields is written inside donedatePicker() function
        default: break
        }
    }
}
