//
//  AppDelegate.swift
//  Lifelist
//
//  Created by Jonathan Arbogast on 1/7/18.
//  Copyright © 2018 Jonathan Arbogast. All rights reserved.
//

import UIKit
import CoreData
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let container = NSPersistentContainer(name: "Lifelist")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            } else {
                distributeModelToViewController(controller: self.window?.rootViewController, container: container)
            }
        }
        
        updateSpeciesList(container: container)
        return true
    }
    
    func updateSpeciesList(container: NSPersistentContainer) {
        var request = URLRequest(url: URL(string: "https://api.ebird.org/v2/ref/taxonomy/ebird?fmt=json")!,timeoutInterval: Double.infinity)
        request.addValue("d00h4dtct1h1", forHTTPHeaderField: "X-eBirdApiToken")

        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
        
            let ebirdSpecies = try! JSONDecoder().decode([EBirdSpecies].self, from: data)
            let context = container.newBackgroundContext()
            context.performAndWait {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Species")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                do {
                    try context.persistentStoreCoordinator?.execute(deleteRequest, with: context)
                } catch let error as NSError {
                    print(String(describing: error))
                }
                
                for ebirdspecie in ebirdSpecies {
                    if let commonName = ebirdspecie.comName, let familyName = ebirdspecie.familyComName {
                        let species = Species(context: context)
                        species.commonName = commonName
                        species.familyCommonName = familyName
                        context.insert(species)
                    }
                }
                
                try! context.save()
            }

        }

        task.resume()
    }

    struct EBirdSpecies: Decodable {
        let comName: String?
        let familyComName: String?
    }
}
