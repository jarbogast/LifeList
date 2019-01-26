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

final class SightingViewController: UITableViewController, LifelistController {
    var persistentContainer: NSPersistentContainer?
    var sighting: Sighting?
    
    @IBOutlet weak var speciesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speciesLabel.text = sighting?.species
    }
}
