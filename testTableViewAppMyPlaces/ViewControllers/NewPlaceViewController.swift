//
//  NewPlaceViewController.swift
//  testTableViewAppMyPlaces
//
//  Created by Алексей Черанёв on 15.07.2021.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    var imageIsChanged = false
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: tableView.frame.size.height))
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
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
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier, let mapVC = segue.destination as? MapViewController else {
            return
        }
        mapVC.incomeSegueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        
        if identifier == "showPlace"
        {
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text!
            mapVC.place.type = placeType.text!
            mapVC.place.imageData = placeImage.image?.pngData()
        }
    }
    
    func savePlace() {
        
        let image = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "imagePlaceholder")
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData,
                             rating: Double(ratingControl.rating))
        
        if currentPlace != nil
        {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.type = newPlace.type
                currentPlace?.location = newPlace.location
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        }
        else
        {
            StorageManager.saveObject(newPlace)
        }
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
    
    private func setupEditScreen() {
        if currentPlace != nil {
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {
                return
            }
            
            setupNavigationBar()
            imageIsChanged = true
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            placeImage.image = image
            ratingControl.rating = Int(currentPlace.rating)
        }
    }
    private func setupNavigationBar()
    {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
}

extension NewPlaceViewController:MapViewControllerDelegate {
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
    
    
}
