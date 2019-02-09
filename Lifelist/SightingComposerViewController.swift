//
//  SightingComposerViewController.swift
//  Lifelist
//
//  Created by Jonathan Arbogast on 1/26/19.
//  Copyright © 2019 Jonathan Arbogast. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class SightingComposerViewController: UITableViewController, LifelistController {
    var persistentContainer: NSPersistentContainer?
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if let species = speciesLabel.text, let dateString = dateLabel.text, let context = persistentContainer?.viewContext {
            let sighting = Sighting(context: context)
            sighting.species = species

            let formatter = SightingDateFormatter()
            sighting.date = formatter.date(from: dateString)

            sighting.image = imageView.image?.pngData()
            
            try! context.save()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 2 else { return }
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
}

extension SightingComposerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SightingComposerViewController: SpeciesViewControllerDelegate {
    func selected(species: String) {
        speciesLabel.text = species
    }
}

extension SightingComposerViewController: DatePickerViewControllerDelegate {
    func didPick(date: Date) {
        let formatter = SightingDateFormatter()
        dateLabel.text = formatter.string(from: date)
    }
    
    
}
