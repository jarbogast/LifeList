//
//  AppDelegate.swift
//  Lifelist
//
//  Created by Jonathan Arbogast on 1/7/18.
//  Copyright © 2018 Jonathan Arbogast. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let container = NSPersistentContainer(name: "Lifel ist")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            } else {
                self.distributeModelToViewController(controller: self.window?.rootViewController, container: container)
            }
        }
        
        return true
    }

    func distributeModelToViewController(controller: UIViewController?, container: NSPersistentContainer) {
        guard let controller = controller else { return }
        
        if let modelController = controller as? LifelistController {
            modelController.persistentContainer = container
        }
        
        for childController in controller.childViewControllers {
            distributeModelToViewController(controller: childController, container: container)
        }
    }
}

