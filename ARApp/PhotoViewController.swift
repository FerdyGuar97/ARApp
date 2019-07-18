//
//  PhotoViewController.swift
//  ARApp
//
//  Created by Ferdinando Guarino on 17/07/2019.
//  Copyright © 2019 Ferdinando Guarino. All rights reserved.
//

import UIKit
import CoreLocation

class PhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descField: UITextField!
    @IBOutlet weak var subtitleField: UITextField!
    
    public var location:CLLocationCoordinate2D!
    public var uuid: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem=UIBarButtonItem(title: "Confirm", style: .plain, target: self, action: #selector(commit))
        // Riconosce la pressione su qualunque punto dello schermo per chiudere la tastiera
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    @IBAction func library(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func album(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func commit() {
        uuid = UUID()
        
        CoreDataController.shared.saveAnnotation(withUUID: uuid!, withTitle: titleField.text!, withSubTitle: subtitleField.text!, withLocation: location)
        
        CoreDataController.shared.saveDocument(withUUID: uuid!, withImage: imageView.image, withDescription: descField.text!)
        
        self.performSegue(withIdentifier: "addSegueUnwind", sender: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
