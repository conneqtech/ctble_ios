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
import RxSwift

struct CTLogObject {
    var date: Date
    var lat: Double
    var lon: Double
    var altitude: Int
}

class DeviceMapViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var updatedOnButton: UIBarButtonItem!
    
    var coords: [CLLocationCoordinate2D] = []
    var log: [CKLocationData] = []
    
    var mapAnnotations: [MKPointAnnotation] = []
    var route: MKPolyline?
    var hideAnnotations = false
    
    let diposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CTBleManager.shared.connectedDevice?.startReportingLocationData()
        self.title = "Locations"
        
        
        let font = UIFont.systemFont(ofSize: 12)
        updatedOnButton.setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedStringKey.font.rawValue): font], for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToLocationUpdates()
        self.map.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.map.delegate = nil
        self.map.removeFromSuperview()
        self.map = nil
        
        super.viewWillDisappear(animated)
    }
    
    @IBAction func exportRoute(_ sender: Any) {
        var text = ""
        log.forEach { item in
            text += "lat: \(item.latitude) lon: \(item.longitude) alt: \(item.altitude) hdop: \(item.hdop) speed: \(item.speed) \n"
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
        if map.mapType == .satellite {
            map.mapType = .standard
        } else {
            map.mapType = .satellite
        }
    }
}

extension DeviceMapViewController: MKMapViewDelegate {
    
    func subscribeToLocationUpdates() {
        
        CTLocationService.shared.locationSubject.subscribe(onNext: { locationData in
            let annotation = MKPointAnnotation()
            annotation.title = "🏎: \(locationData.speed) 🎈:\(locationData.altitude)"
            
            let coord = CLLocationCoordinate2D(latitude: locationData.latitude, longitude: locationData.longitude)
            annotation.coordinate = coord
            
            self.log.append(
                locationData
            )
            
            if !self.coords.contains(where: { c in
                c.latitude == coord.latitude && c.longitude == coord.longitude
            }) {
                self.coords.append(coord)
                self.mapAnnotations.append(annotation)
                
                if !self.hideAnnotations {
                    self.map.addAnnotation(annotation)
                }
                
                if let route = self.route {
                    self.map.remove(route)
                }
                
                self.route = MKPolyline(coordinates: self.coords, count: self.coords.count)
                self.map.add(self.route!)
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            
            
            self.updatedOnButton.title = "Last updated: \(dateFormatter.string(from: Date()))"
        }).disposed(by: diposeBag)
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
