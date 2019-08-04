//
//  NewWishlistItemViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 21/07/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit

class NewWishlistItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, SelectImagePopupViewDelegate {
    
    let imageView = UIImageView()
    let imagePickerController = UIImagePickerController()
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var colorwayTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var releaseDateTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            resetScrollView()
            scrollView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDatePicker()
        setupImagePickerController()
        setupTextFields()
        setupGestureRecognizer()
        setupScrollView()
    }
    
    @IBAction func addPic(_ sender: Any) {
        let selectImagePopup = SelectImagePopupView(with: self)
        
        SwiftEntryKit.display(entry: selectImagePopup, using: selectImagePopup.getAttributes())
    }
    
    @IBAction func addWishlistItem(_ sender: Any) {
        var canSave = true
        
        if let snkrName = nameTextField.text {
            if snkrName.isEmpty {
                canSave = false
                
                let alertPopup = AlertPopup(title: AlertLabels.nameTitle, message: AlertLabels.nameMessage, image: nil)
                SwiftEntryKit.display(entry: alertPopup.getContentView(), using: alertPopup.getAttributes())
            }
        }
        
        if canSave {
            performSegue(withIdentifier: Segues.AddNewWishlistItem, sender: self)
        }
    }
    
    func showDatePicker(){
        //Formate Date
        self.datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        self.releaseDateTextField.inputAccessoryView = toolbar
        self.releaseDateTextField.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        self.releaseDateTextField.text = DateUtils.formatReleaseDate(releaseDate: self.datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image = info[.editedImage] as? UIImage
        
        if image == nil {
            image = info[.editedImage] as? UIImage
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
        self.view.endEditing(true)
        return false
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    internal func librarySelected() {
        self.imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    internal func cameraSelected() {
        self.imagePickerController.sourceType = UIImagePickerController.SourceType.camera
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        if(self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else {
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        }
    }
    
    private func resetScrollView() {
        self.scrollView?.contentSize = imageView.frame.size
        
        let imageViewSize = self.imageView.bounds.size
        let scrollViewSize = self.scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        self.scrollView.minimumZoomScale = max(widthScale, heightScale)
        self.scrollView.maximumZoomScale = 1.0
    }
    
    private func setupImagePickerController() {
        self.imagePickerController.allowsEditing = true
        self.imagePickerController.delegate = self
        self.imagePickerController.mediaTypes = ["public.image", "public.movie"]
    }
    
    private func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTap)
    }
    
    private func setupScrollView() {
        self.scrollView.delegate = self
        self.scrollView.addSubview(self.imageView)
    }
    
    private func setupTextFields() {
        setupNameTextField()
        setupColorwayTextField()
        setupPriceTextField()
        setupReleaseDateTextField()
    }
    
    private func setupNameTextField() {
        self.nameTextField.layer.addSublayer(createBottomBorder(self.nameTextField))
        self.nameTextField.layer.masksToBounds = true
    }
    
    private func setupColorwayTextField() {
        self.colorwayTextField.layer.addSublayer(createBottomBorder(self.colorwayTextField))
        self.colorwayTextField.layer.masksToBounds = true
    }
    
    private func setupPriceTextField() {
        self.priceTextField.layer.addSublayer(createBottomBorder(self.priceTextField))
        self.priceTextField.layer.masksToBounds = true
    }
    
    private func setupReleaseDateTextField() {
        self.releaseDateTextField.layer.addSublayer(createBottomBorder(self.releaseDateTextField))
        self.releaseDateTextField.layer.masksToBounds = true
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
