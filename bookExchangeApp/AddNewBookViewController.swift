//
//  AddNewBookViewController.swift
//  bookExchangeApp
//
//  Created by christy on 24/11/2018.
//  Copyright © 2018 comp4097proj. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import Photos

class AddNewBookViewController: UIViewController {

    @IBOutlet var bookNameTF: UITextField!
    @IBOutlet var authorTF: UITextField!
    
    @IBOutlet var detailTF: UITextField!
    @IBOutlet weak var checkPhotoUpload: UILabel!
    @IBOutlet weak var photoUploadImage: UIImageView!
    
    var userID = ""
    
    var image:UIImage = UIImage()
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.userID = Auth.auth().currentUser!.uid
    }
    

    @IBAction func addBookClicked(_ sender: Any) {
        if(bookNameTF.text == "" || authorTF.text == "" || detailTF.text == "" ){
            let alertController = UIAlertController(title: "Error", message: "Please input all the fields.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        
        let image_set_name:String = "\(self.userID) \(bookNameTF.text ?? "123").jpg"
        
        var ref: DocumentReference? = nil
        ref = Firestore.firestore().collection("Books").addDocument(data: [
            "name": bookNameTF.text ?? "",
            "author": authorTF.text ?? "",
            "ownerId": self.userID,
            "image": image_set_name,
            "detail": detailTF.text ?? "",
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                let alertController = UIAlertController(title: "Add New Book", message: "Successfully", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(alertAction)in self.navigationController?.popViewController(animated: true)}))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
       

        let imageData: Data = UIImagePNGRepresentation(image)!
//        UIImage(data:imageData,scale:1.0)
        
        // Create a reference to the file you want to upload
        let storageRef = Storage.storage().reference()
        let folderRef = storageRef.child("Book")
        let riversRef = folderRef.child(image_set_name)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        // Upload the file to the path "images/rivers.jpg"
        _ = riversRef.putData(imageData, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            _ = metadata.size
            // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
            }
        }
    }

    @IBAction func addPhotoFromLibary(_ sender: Any) {
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
            case .authorized:
                self.addPhotoFromLibaryGo()
                print("Access is granted by user")
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (newStatus) in print("status is \(newStatus)")
                    if newStatus == PHAuthorizationStatus.authorized {
                        print("success")
                        self.addPhotoFromLibaryGo()
                    }
                })
            case .restricted:
                print("User do not have access to photo album.")
            case .denied:
                print("User has denied the permission.")
            
        }
        
    }
        
    func addPhotoFromLibaryGo(){
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
              print("can't open photo library")
              return
        }
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    // unfinished
    @IBAction func addPhotoFromCamera(_ sender: Any) {
        
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status{
        case .authorized: // The user has previously granted access to the camera.
            self.addPhotoFromCameraGo()
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.addPhotoFromCameraGo()
                } else {
                    self.addAlertForSettings()
                }
            }
            //denied - The user has previously denied access.
        //restricted - The user can't grant access due to restrictions.
        case .denied, .restricted:
            self.addAlertForSettings()
            return
            
        default:
            break
        }
    }
    
    func addAlertForSettings(){
        let alert = UIAlertController(title: "Alert", message: "We need the permission", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "I'll do it later", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addPhotoFromCameraGo(){
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("camera not supported by this device")
            return
        }
        
        imagePicker.sourceType = .camera
        imagePicker.delegate = self

        present(imagePicker, animated: true)
    }
    
}

extension AddNewBookViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        defer {
//            picker.dismiss(animated: true)
//        }
//
//        print(info)
//    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            picker.dismiss(animated: true)
        }
        
        print("did cancel")
    }
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.image = image
        self.photoUploadImage.image = image
        
        print("---------hihihi i hihihi_______")
        self.checkPhotoUpload.text = "You have uploaded"
        
        
        picker.dismiss(animated:true, completion: nil)
        
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
