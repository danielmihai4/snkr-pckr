//
//  NewSnkrViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 17/11/2018.
//  Copyright © 2018 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit

class NewSnkrViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, SelectImagePopupViewDelegate {
    
    var imageView = UIImageView()
    var imagePickerController = UIImagePickerController()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var colorwayTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            resetScrollView()
            scrollView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupImagePickerController()
        setupTextFields()
        setupGestureRecognizer()
        setupScrollView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func addPic(_ sender: Any) {
        let selectImagePopup = SelectImagePopupView(delegate: self, withUrlDownload: false)
        
        SwiftEntryKit.display(entry: selectImagePopup, using: selectImagePopup.getAttributes())
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
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image = info[.originalImage] as? UIImage
        
        if image == nil {
            image = info[.originalImage] as? UIImage
        }
        
        self.imageView.image = image
        self.imageView.sizeToFit()
        resetScrollView()
        picker.dismiss(animated: true,completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
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
    
    func resetScrollView() {
        scrollView?.contentSize = imageView.frame.size
        
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = max(widthScale, heightScale)
        scrollView.maximumZoomScale = 1.0
    }
    
    @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)            
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    internal func librarySelected() {
        self.imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    internal func cameraSelected() {
        self.imagePickerController.sourceType = UIImagePickerController.SourceType.camera
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    internal func urlDownloadSelected() {
        //not needed
    }
    
    private func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    private func setupImagePickerController() {
        self.imagePickerController.allowsEditing = false
        self.imagePickerController.delegate = self
        self.imagePickerController.mediaTypes = ["public.image", "public.movie"]
    }
    
    private func setupTextFields() {
        setupNameTextField()
        setupColorwayTextField()
    }
    
    private func setupNameTextField() {
        self.nameTextField.layer.masksToBounds = true
        self.nameTextField.delegate = self
        addBorder(edge: .bottom, textField: self.nameTextField)
    }
    
    private func setupColorwayTextField() {
        self.colorwayTextField.layer.masksToBounds = true
        self.colorwayTextField.delegate = self
        addBorder(edge: .bottom, textField: self.colorwayTextField)
    }
    
    private func setupScrollView() {
        self.scrollView.delegate = self
        self.scrollView.addSubview(self.imageView)
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

        border.backgroundColor =  Colors.dustStorm.cgColor

        textField.layer.addSublayer(border)
    }
}
