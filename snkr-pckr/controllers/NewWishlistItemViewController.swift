//
//  NewWishlistItemViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 21/07/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit
import YPImagePicker

class NewWishlistItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, SelectImagePopupViewDelegate, UrlDownloadPopupDelegate {
      
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var colorwayTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var releaseDateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showDatePicker()
        self.setupTextFields()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let selectImagePopup = SelectImagePopupView(delegate: self, withUrlDownload: true)

        SwiftEntryKit.display(entry: selectImagePopup, using: selectImagePopup.getAttributes())
    }
    
    @IBAction func addPic(_ sender: Any) {
        let selectImagePopup = SelectImagePopupView(delegate: self, withUrlDownload: true)

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
        self.datePicker.datePickerMode = .date
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        self.releaseDateTextField.inputAccessoryView = toolbar
        self.releaseDateTextField.inputView = datePicker
        
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
    
    @objc func donedatePicker(){
        self.releaseDateTextField.text = DateUtils.formatReleaseDate(releaseDate: self.datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image = info[.originalImage] as? UIImage
        
        if image == nil {
            image = info[.originalImage] as? UIImage
        }
        
        self.imageView.image = image
        self.imageView.sizeToSuperview()
        picker.dismiss(animated: true,completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
        return self.imageView
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    internal func imagePickerSelected() {
        let imagePicker = YPImagePicker(configuration: PickerConfiguration.configuration())
        imagePicker.didFinishPicking { [unowned imagePicker] items, _ in
            if let photo = items.singlePhoto {
                self.imageView.image = photo.image
                self.imageView.sizeToFit()
            }
            imagePicker.dismiss(animated: true, completion: nil)
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    internal func urlDownloadSelected() {
        let downloadUrlPopup = UrlDownloadPopup(self)
        SwiftEntryKit.display(entry: downloadUrlPopup.getContentView(), using: downloadUrlPopup.getAttributes(), presentInsideKeyWindow: true)
    }
    
    internal func download(urlString: String) {
        if verifyUrl(urlString: urlString) {
            if (isInstagram(urlString: urlString)) {
                var components = URLComponents(string: urlString)
                components?.query = nil
                components?.path += "media"
                components?.queryItems = [URLQueryItem(name: "size", value: "l")]
                    
                if let components = components {
                    downloadImage(from: (components.url)!)
                    return
                }
            } else {
                downloadImage(from: URL(string: urlString)!)
                return
            }
        }
            
        showCannotLoadImagePopup()
    }
    
    private func showCannotLoadImagePopup() {
        let alertPopup = AlertPopup(title: AlertLabels.cannotLoadImageTitle, message: AlertLabels.cannotLoadImageMessage, image: nil)
        SwiftEntryKit.display(entry: alertPopup.getContentView(), using: alertPopup.getAttributes())
    }
    
    private func setupTextFields() {
        setupNameTextField()
        setupColorwayTextField()
        setupPriceTextField()
        setupReleaseDateTextField()
    }
    
    private func setupNameTextField() {
        self.nameTextField.layer.addSublayer(createBottomBorder(self.nameTextField))
        self.nameTextField.delegate = self
        self.nameTextField.layer.masksToBounds = true
    }
    
    private func setupColorwayTextField() {
        self.colorwayTextField.layer.addSublayer(createBottomBorder(self.colorwayTextField))
        self.colorwayTextField.delegate = self
        self.colorwayTextField.layer.masksToBounds = true
    }
    
    private func setupPriceTextField() {
        self.priceTextField.layer.addSublayer(createBottomBorder(self.priceTextField))
        self.priceTextField.delegate = self
        self.priceTextField.layer.masksToBounds = true
    }
    
    private func setupReleaseDateTextField() {
        self.releaseDateTextField.layer.addSublayer(createBottomBorder(self.releaseDateTextField))
        self.releaseDateTextField.delegate = self
        self.releaseDateTextField.layer.masksToBounds = true
    }
    
    private func createBottomBorder(_ textField: UITextField) -> CALayer {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = Colors.dustStorm.cgColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
        border.borderWidth = width
        
        return border
    }
    
    private func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
                self.imageView.sizeToFit()                
            }
        }
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    private func verifyUrl(urlString: String?) -> Bool {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return false
        }

        return UIApplication.shared.canOpenURL(url)
    }
    
    private func isInstagram(urlString: String) -> Bool {
        let url = URL(string: urlString)
        let domain = url?.host
        
        return domain?.contains("instagram") ?? false
    }
}
