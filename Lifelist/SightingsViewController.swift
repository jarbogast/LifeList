//
//  SightingsViewController.swift
//  Lifelist
//
//  Created by Jonathan Arbogast on 1/7/18.
//  Copyright © 2018 Jonathan Arbogast. All rights reserved.
//

import UIKit
import CoreData

class SightingsViewController: UITableViewController, LifelistController {

    var fetchedResultsController: NSFetchedResultsController<Sighting>?

    var persistentContainer: NSPersistentContainer? {
        didSet {
            let fetchRequest = NSFetchRequest<Sighting>(entityName: "Sighting")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "yearAndMonth", ascending: false), NSSortDescriptor(key: "species", ascending: true)]
            if let context = persistentContainer?.viewContext {
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                      managedObjectContext: context,
                                                                      sectionNameKeyPath: "yearAndMonth", cacheName: nil)
                fetchedResultsController?.delegate = self
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error while fetching sightings")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        distributeModelToViewController(controller: segue.destination, container: persistentContainer)

        if let sightingController = segue.destination as? SightingViewController, let cell = sender as? UITableViewCell {
            sightingController.sighting = fetchedResultsController?.object(at: tableView.indexPath(for: cell)!)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = fetchedResultsController {
            return frc.sections!.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SightingCell")!
        configure(cell: cell, at: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            return nil
        }

        let firstSighting = sectionInfo.objects![0] as! Sighting
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: firstSighting.yearAndMonth!)
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let result = fetchedResultsController?.section(forSectionIndexTitle: title, at: index) else {
            fatalError("Unable to locate section for \(title) at index: \(index)")
        }
        return result
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let context = persistentContainer?.viewContext else { return }
        guard let sighting = fetchedResultsController?.object(at: indexPath) else { return }

        context.delete(sighting)
        do {
            try context.save()
        } catch {
            print("Error while saving context: \(error)")
        }
    }

    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        guard let object = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }

        cell.textLabel?.text = object.species
        
        if let date = object.date {
            let formatter = SightingDateFormatter()
            cell.detailTextLabel?.text = formatter.string(from: date)
        }
        
        if let imageData = object.image {
            cell.imageView?.image = UIImage(data: imageData)
        }
    }
}

extension SightingsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
                    at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configure(cell: tableView.cellForRow(at: indexPath!)!, at: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        @unknown default:
            fatalError()
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
