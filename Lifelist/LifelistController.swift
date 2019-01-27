//
//  LifelistController.swift
//  Lifelist
//
//  Created by Jonathan Arbogast on 1/7/18.
//  Copyright © 2018 Jonathan Arbogast. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol LifelistController: class {
    var persistentContainer: NSPersistentContainer? { get set }
}

func distributeModelToViewController(controller: UIViewController?, container: NSPersistentContainer?) {
    guard let controller = controller else { return }
    
    if let modelController = controller as? LifelistController {
        modelController.persistentContainer = container
    }
    
    for childController in controller.children {
        distributeModelToViewController(controller: childController, container: container)
    }
}
