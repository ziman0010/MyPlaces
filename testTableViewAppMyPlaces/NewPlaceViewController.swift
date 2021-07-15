//
//  NewPlaceViewController.swift
//  testTableViewAppMyPlaces
//
//  Created by Алексей Черанёв on 15.07.2021.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    var imageIsChanged = false
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var placeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    //MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo",
                                      style: .default)
            { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            present(actionSheet, animated: true, completion: nil)
        }
        else
        {
            view.endEditing(true)
        }
    }
    
    func saveNewPlace() {
        var image: UIImage?
        
        if imageIsChanged
        {
            image = placeImage.image
        }
        else
        {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        let imageData = image?.pngData()
        let newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData)
        StorageManager.saveObject(newPlace)
    }
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: Text Field Delegate
extension NewPlaceViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc private func textFieldChanged() {
        if placeName.text?.isEmpty == false
        {
            saveButton.isEnabled = true
        }
        else
        {
            saveButton.isEnabled = false
        }
    }
}

//MARK: Work with an image
extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func chooseImagePicker(source: UIImagePickerController.SourceType)
    {
        if UIImagePickerController.isSourceTypeAvailable(source)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true, completion: nil)
    }
}
