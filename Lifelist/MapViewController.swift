//
//  MapViewController.swift
//  Lifelist
//
//  Created by Jonathan Arbogast on 12/7/20.
//  Copyright © 2020 Jonathan Arbogast. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class MapViewController: UIViewController, LifelistController {
    @IBOutlet weak var mapView: MKMapView!

    var fetchedResultsController: NSFetchedResultsController<Sighting>?

    var persistentContainer: NSPersistentContainer? {
        didSet {
            let fetchRequest = NSFetchRequest<Sighting>(entityName: "Sighting")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "species", ascending: true)]
            if let context = persistentContainer?.viewContext {
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                      managedObjectContext: context,
                                                                      sectionNameKeyPath: nil, cacheName: nil)
                fetchedResultsController?.delegate = self
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            for sighting in fetchedResultsController!.fetchedObjects! {
                mapView.addAnnotation(sighting)
            }
            mapView.fitAll()
        } catch {
            print("Error while fetching sightings")
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            annotationView!.clusteringIdentifier = "Sighting"
        } else {
            annotationView!.annotation = annotation
            annotationView!.clusteringIdentifier = "Sighting"
        }
        
        if let sighting = annotation as? Sighting, let imageData = sighting.image {
            let imageView = UIImageView(image: UIImage(data: imageData))
            imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            annotationView?.leftCalloutAccessoryView = imageView
        } else {
            annotationView?.leftCalloutAccessoryView = nil
        }

        return annotationView
    }
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
                    at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let sighting = anObject as? Sighting else {
            fatalError()
        }
        
        if (!CLLocationCoordinate2DIsValid(sighting.coordinate)) {
            return
        }
        
        switch type {
        case .insert:
            mapView.addAnnotation(sighting)
        case .delete:
            mapView.removeAnnotation(sighting)
        case .move:
            fallthrough
        case .update:
            mapView.removeAnnotation(sighting)
            mapView.addAnnotation(sighting)
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        mapView.fitAll()
    }
}

extension Sighting: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        if latitude.isZero || longitude.isZero {
            return kCLLocationCoordinate2DInvalid
        }
        
        let latDegrees = CLLocationDegrees(latitude)
        let longDegrees = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
    
    public var title: String? {
        return species
    }
    
    public var subtitle: String? {
        guard let date = date else {
            return nil
        }
        
        let formatter = SightingDateFormatter()
        return formatter.string(from: date)
    }
}

extension MKMapView {
    /// when we call this function, we have already added the annotations to the map, and just want all of them to be displayed.
    func fitAll() {
        var zoomRect            = MKMapRect.null;
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect       = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect            = zoomRect.union(pointRect)
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
}
