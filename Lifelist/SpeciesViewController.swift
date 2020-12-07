//
//  SpeciesViewController.swift
//  Lifelist
//
//  Created by Jonathan Arbogast on 1/26/19.
//  Copyright © 2019 Jonathan Arbogast. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol SpeciesViewControllerDelegate: class {
    func selected(species: String)
}

final class SpeciesViewController: UITableViewController, LifelistController {
    weak var delegate: SpeciesViewControllerDelegate?
    var fetchedResultsController: NSFetchedResultsController<Species>?
    var searchController = UISearchController(searchResultsController: nil)
    var filteredSpecies = [Species]()
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }

    var persistentContainer: NSPersistentContainer? {
        didSet {
            let fetchRequest = NSFetchRequest<Species>(entityName: "Species")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "familyCommonName", ascending: true), NSSortDescriptor(key: "commonName", ascending: true)]
            if let context = persistentContainer?.viewContext {
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                      managedObjectContext: context,
                                                                      sectionNameKeyPath: "familyCommonName", cacheName: nil)
                fetchedResultsController?.delegate = self
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SpeciesCell")

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Species"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error while fetching sightings")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let species: Species
        
        if isFiltering {
            species = filteredSpecies[indexPath.row]
        } else {
            species = self.fetchedResultsController!.object(at: indexPath)
        }
        
        guard let commonName = species.commonName else {
            fatalError("Attempt to select species with no name")
        }

        delegate?.selected(species: commonName)
        navigationController?.popViewController(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        }
        
        if let frc = fetchedResultsController {
            return frc.sections!.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredSpecies.count
        }
        
        guard let sections = self.fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpeciesCell")!
        configure(cell: cell, at: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return nil
        }
        
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            return nil
        }
        return sectionInfo.name
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isFiltering {
            return nil
        }
        
        return fetchedResultsController?.sectionIndexTitles
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if isFiltering {
            return 0
        }
        
        guard let result = fetchedResultsController?.section(forSectionIndexTitle: title, at: index) else {
            fatalError("Unable to locate section for \(title) at index: \(index)")
        }
        return result
    }

    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        let species: Species
        
        if isFiltering {
            species = filteredSpecies[indexPath.row]
        } else {
            species = self.fetchedResultsController!.object(at: indexPath)
        }

        cell.textLabel?.text = species.commonName
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredSpecies = fetchedResultsController?.fetchedObjects?.filter { (species: Species) -> Bool in
            return (species.commonName?.lowercased().contains(searchText.lowercased()) ?? false)
        } ?? [Species]()
      
      tableView.reloadData()
    }

}

extension SpeciesViewController: NSFetchedResultsControllerDelegate {
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

extension SpeciesViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}

