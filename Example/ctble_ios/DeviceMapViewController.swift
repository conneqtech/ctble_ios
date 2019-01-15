//
//  DeviceMapViewController.swift
//  ctble_Example
//
//  Created by Gert-Jan Vercauteren on 15/01/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import ctble
import MapKit

struct CTLogObject {
    var date: Date
    var lat: Double
    var lon: Double
    var altitude: Int
}

class DeviceMapViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var mapType: UISegmentedControl!
    
    var coords: [CLLocationCoordinate2D] = []
    var log: [CTLogObject] = []
    
    var mapAnnotations: [MKPointAnnotation] = []
    var route: MKPolyline?
    var hideAnnotations = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CTBleManager.shared.connectedDevice?.startReportingLocationData()
        CTLocationService.shared.delegate = self
        self.title = "Locations"
        self.map.delegate = self
    }
    
    @IBAction func exportRoute(_ sender: Any) {
        var text = ""
        log.forEach { item in
            text += "[\(item.date)] lat: \(item.lat) lon: \(item.lon) alt: \(item.altitude)\n"
        }
        
        let shareAll = [text]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func toggleAnnotations(_ sender: Any) {
        hideAnnotations = !hideAnnotations
        
        if hideAnnotations {
            map.removeAnnotations(mapAnnotations)
        } else {
            map.addAnnotations(mapAnnotations)
        }
    }
    
    @IBAction func changeMapType(_ sender: Any) {
        switch mapType.selectedSegmentIndex {
        case 0:
            map.mapType = .standard
        case 1:
            map.mapType = .satellite
        default:
            break
        }
    }
}

extension DeviceMapViewController: CTLocationServiceDelegate, MKMapViewDelegate {
    func didUpdateLocation(deviceName: String, lat: Double, lon: Double, altitude: Int) {
        let annotation = MKPointAnnotation()
        annotation.title = "alt: \(altitude)"
        
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        annotation.coordinate = coord
        
        log.append(
            CTLogObject(date: Date(),
                        lat: lat,
                        lon: lon,
                        altitude:altitude)
        )
        
        if !coords.contains(where: { c in
            c.latitude == coord.latitude && c.longitude == coord.longitude
        }) {
            self.coords.append(coord)
            self.mapAnnotations.append(annotation)
            
            if !hideAnnotations {
                self.map.addAnnotation(annotation)
            }
           
            if let route = route {
                 self.map.remove(route)
            }
            
            route = MKPolyline(coordinates: coords, count: coords.count)
            self.map.add(route!)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        self.title = "Last refresh: \(dateFormatter.string(from: Date()))"
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Return an `MKPolylineRenderer` for the `MKPolyline` in the `MKMapViewDelegate`s method
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .blue
            testlineRenderer.lineWidth = 2
            return testlineRenderer
        }
        fatalError("Something wrong...")
        //return MKOverlayRenderer()
    }
}
