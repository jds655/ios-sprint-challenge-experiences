//
//  ViewController.swift
//  Experiences
//
//  Created by Lambda_School_Loaner_214 on 11/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var experienceController = ExperienceController()
    var touchLocation: CLLocationCoordinate2D?

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        //centerMapOnLocation()
        //let annotations = mapView.annotations.compactMap({ $0 as? Experience })
        mapView.addAnnotations(experienceController.experiences)
        mapView.showAnnotations(experienceController.experiences, animated: true)
    }
    
    private func centerMapOnLocation() {
        if let mapCenter = locationManager.location?.coordinate {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: mapCenter, span: span)
            mapView.setRegion(region, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
    }
    
    private func setupMapView () {
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "ExperienceView")
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.requestLocation()
            centerMapOnLocation()
        default:
            break
        }
    }
    
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let alert = UIAlertController(title: "Add Experience?", message: "Do you want to add an Experience here?", preferredStyle: .actionSheet)
            let actionOK = UIAlertAction(title: "Yes", style: .default) { (_) in
                //TODO: Add annotation
                let touchLocation = sender.location(in: self.mapView)
                let locationCoordinate = self.mapView.convert(touchLocation, toCoordinateFrom: self.mapView)
                self.touchLocation = locationCoordinate
                self.performSegue(withIdentifier: "AddExperienceSegue", sender: self)
            }
            let actionCancel = UIAlertAction(title: "No", style: .destructive, handler: nil)
            alert.addAction(actionOK)
            alert.addAction(actionCancel)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ExperienceViewController else { return }
        vc.experienceController = self.experienceController
        switch segue.identifier {
        case "AddExperienceSegue":
            vc.coordinate =  touchLocation //locationManager.location?.coordinate
        case "ViewExperienceSegue":
            guard let experience = sender as? Experience else { return }
            vc.experience = experience
            break
        default:
            break
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let experience = view.annotation as? Experience else { return }
        self.performSegue(withIdentifier: "ViewExperienceSegue", sender: experience)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Location manager failed with error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        locationManager.requestLocation()
    }
}
