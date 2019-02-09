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
        speciesLabel.text = sighting?.species
        
        if let date = sighting?.date {
            let formatter = SightingDateFormatter()
            dateLabel.text = formatter.string(from: date)
        }
        
        if let data = sighting?.image, let image = UIImage(data: data) {
            imageView.image = image
        }
    }
}
