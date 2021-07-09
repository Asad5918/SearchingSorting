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
    
    var itemArray = [Items]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let datePicker = UIDatePicker()
    var gender: String = ""
    override func viewDidLoad() {
        imageView.layer.cornerRadius = imageView.frame.height/2 // For round imageView
        imageView.layer.masksToBounds = true
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        showDatePicker()

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //loadItems()
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
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
   
    // To select and display image
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
        formatter.dateFormat = "dd/MM/yyyy"
        dobPicker.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
        print(dobPicker.text!)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
  
//    func getAgeFromDOF(date: String) -> Array<Int> {
//
//        let dateFormater = DateFormatter()
//        dateFormater.dateFormat = "dd/MM/yyyy"
//        let dateOfBirth = dateFormater.date(from: date)
//
//        let calender = Calendar.current
//
//        let dateComponent = calender.dateComponents([.year, .month, .day], from:
//            dateOfBirth!, to: Date())
//
//        return [dateComponent.year!, dateComponent.month!, dateComponent.day!]
//    }
//
//    let age  = getAgeFromDOF(date: "01/12/2000")
//    print(age)
//    print(age[0])
//    print(age[1])
//    print(age[2])

    
//    //Calls this function when the tap is recognized.
//    @objc func dismissKeyboard() {
//        //Causes the view (or one of its embedded text fields) to resign the first responder status.
//        view.endEditing(true)
//    }
    //MARK: - Save button
    @IBOutlet weak var save: UIButton!
    @IBAction func saveClicked(_ sender: UIButton) {
        //let text = fName.text ?? ""
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
            //save.isEnabled = !text.isEmpty
            let newItem = Items(context: context)
            newItem.fName = fName.text!
            newItem.lName = lName.text!
            newItem.dateofbirth = dobPicker.text!
            newItem.gender = gender
            newItem.image = (imageView.image?.pngData())!
            newItem.aboutMe = aboutMe.text!
            
            saveItems()
            // for console check
            print(newItem.fName!)
            print(newItem.lName!)
            print(newItem.dateofbirth!)
            print(newItem.gender!)
            print(newItem.image!)
            print(newItem.aboutMe!)
            
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
