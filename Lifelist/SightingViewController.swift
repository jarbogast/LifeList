//
//  SightingViewController.swift
//  Lifelist
//
//  Created by Jonathan Arbogast on 1/26/19.
//  Copyright © 2019 Jonathan Arbogast. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Photos

final class SightingViewController: UIViewController, LifelistController {
    var persistentContainer: NSPersistentContainer?
    var sighting: Sighting?
    var location: CLLocation?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var speciesLabel: UILabel!

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped(_:)))
        }
        
        if let species = sighting?.species {
            speciesLabel.text = species.count > 0 ? species : "Species"
        }

        if let date = sighting?.date {
            datePicker.date = date
        }

        if let data = sighting?.image, let image = UIImage(data: data) {
            imageView.image = image
        }
        
        if (PHPhotoLibrary.authorizationStatus() == .notDetermined) {
            PHPhotoLibrary.requestAuthorization { status in
                
            }
        }
    }
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if let species = speciesLabel.text, let context = persistentContainer?.viewContext {
            if sighting == nil { sighting = Sighting(context: context) }
            if let sighting = sighting {
                sighting.species = species
                sighting.date = datePicker.date
                
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month], from: datePicker.date)
                sighting.yearAndMonth = calendar.date(from: components)!
                
                sighting.image = imageView.image?.jpegData(compressionQuality: 1.0)

                if let location = location {
                    sighting.latitude = location.coordinate.latitude
                    sighting.longitude = location.coordinate.longitude
                }
                
                do {
                    try context.save()
                } catch {
                    print("Error while saving context: \(error)")
                }
            }
        }
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let speciesViewController = segue.destination as? SpeciesViewController {
            speciesViewController.delegate = self
            distributeModelToViewController(controller: speciesViewController, container: persistentContainer)
        }
    }

    @IBAction func imageViewTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
}

extension SightingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        imageView.image = info[.originalImage] as? UIImage
        if let asset = info[.phAsset] as? PHAsset {
            if let creationDate = asset.creationDate {
                datePicker.date = creationDate
            }
            
            location = asset.location
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SightingViewController: SpeciesViewControllerDelegate {
    func selected(species: String) {
        speciesLabel.text = species
    }
}

extension UIImage {

    func getExifData() -> CFDictionary? {
        var exifData: CFDictionary? = nil
        if let data = self.jpegData(compressionQuality: 1.0) {
            data.withUnsafeBytes {
                let bytes = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
                if let cfData = CFDataCreate(kCFAllocatorDefault, bytes, data.count),
                    let source = CGImageSourceCreateWithData(cfData, nil) {
                    exifData = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
                }
            }
        }
        return exifData
    }
}
