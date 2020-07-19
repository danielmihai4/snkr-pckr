//
//  NewSnkrViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 17/11/2018.
//  Copyright © 2018 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit
import YPImagePicker

class NewSnkrViewController: UIViewController, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate {
   
    var selectedImage: UIImage?
    var snkrToEdit: Snkr?
    var snkrService = SnkrService()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var colorwayTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        
        if snkrToEdit == nil  {
            if selectedImage == nil {
                performSegue(withIdentifier: Segues.CancelNewSnkrSegue, sender: nil)
                return
            }
            
            imageView.image = selectedImage
        } else {
            imageView.image = snkrService.loadPic(snkr: snkrToEdit!)
            nameTextField.text = snkrToEdit?.name
            colorwayTextField.text = snkrToEdit?.colorway
            self.title = "Edit Snkr"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func addPic(_ sender: Any) {
        let picker = YPImagePicker(configuration: PickerConfiguration.configuration())
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.imageView.image = photo.image
                self.imageView.sizeToFit()
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func addSnkr(_ sender: Any) {
        var canSave = true
        
        if let snkrName = nameTextField.text {
            if snkrName.isEmpty {
                canSave = false
                
                let alertPopup = AlertPopup(title: AlertLabels.nameTitle, message: AlertLabels.nameMessage, image: nil)
                SwiftEntryKit.display(entry: alertPopup.getContentView(), using: alertPopup.getAttributes())
            }
        }
        
        if canSave {
            performSegue(withIdentifier: Segues.AddNewSnkr, sender: self)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    internal func urlDownloadSelected() {
        //not needed
    }
    
    private func setupTextFields() {
        setupNameTextField()
        setupColorwayTextField()
    }
    
    private func showPicker() {
        let picker = YPImagePicker(configuration: PickerConfiguration.configuration())
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.imageView.image = photo.image
                self.imageView.sizeToFit()
            } else {
                self.performSegue(withIdentifier: Segues.CancelNewSnkrSegue, sender: nil)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    private func setupNameTextField() {
        self.nameTextField.layer.masksToBounds = true
        self.nameTextField.delegate = self
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: Placeholders.name, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        addBorder(edge: .bottom, textField: self.nameTextField)
    }
    
    private func setupColorwayTextField() {
        self.colorwayTextField.layer.masksToBounds = true
        self.colorwayTextField.delegate = self
        self.colorwayTextField.attributedPlaceholder = NSAttributedString(string: Placeholders.colorway, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        addBorder(edge: .bottom, textField: self.colorwayTextField)
    }
    
    private func addBorder(edge: UIRectEdge, textField: UITextField) {
        let border = CALayer()
        let thickness = CGFloat(1.0)
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: textField.frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: textField.frame.height - thickness, width: textField.frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: textField.frame.height)
        case .right:
            border.frame = CGRect(x: textField.frame.width - thickness, y: 0, width: thickness, height: textField.frame.height)
        default:
            break
        }

        border.backgroundColor =  UIColor.white.cgColor

        textField.layer.addSublayer(border)
    }
}
