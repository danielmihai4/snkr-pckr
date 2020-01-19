//
//  NewWishlistItemViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 21/07/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit

class NewWishlistItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, SelectImagePopupViewDelegate, UrlDownloadPopupDelegate {
    
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
            self.scrollView.delegate = self
            self.scrollView.addConstraint(NSLayoutConstraint(item: self.scrollView,
                                                             attribute: NSLayoutConstraint.Attribute.height,
                                                             relatedBy: NSLayoutConstraint.Relation.equal,
                                                             toItem: self.scrollView,
                                                             attribute: NSLayoutConstraint.Attribute.width,
                                                             multiplier: 56 / 75,
                                                             constant: 0))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDatePicker()
        setupImagePickerController()
        setupTextFields()
        setupGestureRecognizer()
        setupScrollView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        self.resetScrollView()
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
    
    @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        if(self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else {
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        }
    }
    
    private func showCannotLoadImagePopup() {
        let alertPopup = AlertPopup(title: AlertLabels.cannotLoadImageTitle, message: AlertLabels.cannotLoadImageMessage, image: nil)
        SwiftEntryKit.display(entry: alertPopup.getContentView(), using: alertPopup.getAttributes())
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
        self.imagePickerController.allowsEditing = false
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
                self.resetScrollView()
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
