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

final class SightingViewController: UIViewController, LifelistController {
    var persistentContainer: NSPersistentContainer?
    var sighting: Sighting?

    @IBOutlet weak var speciesLabel: UILabel! {
        didSet {
            speciesLabel.layer.cornerRadius = 5
            speciesLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var dateLabel: UILabel! {
        didSet {
            dateLabel.layer.cornerRadius = 5
            dateLabel.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let species = sighting?.species {
            speciesLabel.text = species.count > 0 ? species : "Species"
        }

        if let date = sighting?.date {
            let formatter = SightingDateFormatter()
            dateLabel.text = formatter.string(from: date)
        }

        if let data = sighting?.image, let image = UIImage(data: data) {
            imageView.image = image
        }
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if let species = speciesLabel.text, let dateString = dateLabel.text, let context = persistentContainer?.viewContext {
            if sighting == nil { sighting = Sighting(context: context) }
            if let sighting = sighting {
                sighting.species = species

                let formatter = SightingDateFormatter()
                sighting.date = formatter.date(from: dateString)
                sighting.image = imageView.image?.jpegData(compressionQuality: 1.0)

                do {
                    try context.save()
                } catch {
                    print("Error while saving context: \(error)")
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let speciesViewController = segue.destination as? SpeciesViewController {
            speciesViewController.delegate = self
        }

        if let datePickerViewController = segue.destination as? DatePickerViewController {
            datePickerViewController.delegate = self
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
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SightingViewController: SpeciesViewControllerDelegate {
    func selected(species: String) {
        speciesLabel.text = species
    }
}

extension SightingViewController: DatePickerViewControllerDelegate {
    func didPick(date: Date) {
        let formatter = SightingDateFormatter()
        dateLabel.text = formatter.string(from: date)
    }
}
