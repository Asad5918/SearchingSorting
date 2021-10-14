//
//  EnterDetailsViewController.swift
//  SearchingSorting
//
//  Created by ebsadmin on 24/06/21.
//  Copyright © 2021 droisys. All rights reserved.
//

import UIKit
import CoreData

class EnterDetailsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
    
    var itemArray = [Items]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let datePicker = UIDatePicker()
    var gender: String = ""
    var age:[Int] = []
    static var hasDataEntered: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        print("V2 viewDidLoad called")
        imageView.layer.cornerRadius = imageView.frame.height/2 // For round imageView
        imageView.layer.masksToBounds = true
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        showDatePicker()
        
        self.fName.delegate = self
        self.lName.delegate = self
        self.dobPicker.delegate = self

        labelLastName.isHidden = true
        lName.isHidden = true
        labelDob.isHidden = true
        dobPicker.isHidden = true
        labelGender.isHidden = true
        genderButtons[0].isHidden = true
        labelMale.isHidden = true
        genderButtons[1].isHidden = true
        labelFemale.isHidden = true
        labelAboutMe.isHidden = true
        aboutMe.isHidden = true
        imageView.isHidden = true
        btnSelectImage.isHidden = true
        btnSave.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EnterDetailsViewController.hasDataEntered = false
        print("V2 viewWillAppear called")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("V2 viewDidAppear called")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("V2 viewWillDisappear called")
        print(EnterDetailsViewController.hasDataEntered)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("V2 viewDidDisappear called")
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
        if age[0] < 16 {
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
        print(age)
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
            let newItem = Items(context: context)
            newItem.fName = fName.text!
            newItem.lName = lName.text!
            newItem.dateofbirth = dobPicker.text!
            newItem.gender = gender
            newItem.image = (imageView.image?.pngData())!
            newItem.aboutMe = aboutMe.text!
            newItem.age = age
            newItem.name = fName.text! + " " + lName.text!
            EnterDetailsViewController.hasDataEntered = true
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
extension EnterDetailsViewController: UITextFieldDelegate {
    
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

