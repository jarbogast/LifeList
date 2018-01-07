//
//  LifelistController.swift
//  Lifelist
//
//  Created by Jonathan Arbogast on 1/7/18.
//  Copyright © 2018 Jonathan Arbogast. All rights reserved.
//

import Foundation
import CoreData

protocol LifelistController: class {
    var persistentContainer: NSPersistentContainer { get set }
}
