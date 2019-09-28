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
    }
    
    @IBAction func addPic(_ sender: Any) {
        let selectImagePopup = SelectImagePopupView(with: self)
        
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
        self.nameTextField.layer.addSublayer(createBottomBorder(self.nameTextField))
        self.nameTextField.layer.masksToBounds = true
        self.nameTextField.delegate = self
    }
    
    private func setupColorwayTextField() {
        self.colorwayTextField.layer.addSublayer(createBottomBorder(self.colorwayTextField))
        self.colorwayTextField.layer.masksToBounds = true
        self.colorwayTextField.delegate = self
    }
    
    private func setupScrollView() {
        self.scrollView.delegate = self
        self.scrollView.addSubview(self.imageView)
    }
    
    private func createBottomBorder(_ textField: UITextField) -> CALayer {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = Colors.pastelGrey.cgColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
        border.borderWidth = width
        
        return border
    }
}
