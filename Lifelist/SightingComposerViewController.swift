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
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if let species = speciesLabel.text, let dateString = dateLabel.text, let context = persistentContainer?.viewContext {
            let sighting = Sighting(context: context)
            sighting.species = species

            let formatter = SightingDateFormatter()
            sighting.date = formatter.date(from: dateString)

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
