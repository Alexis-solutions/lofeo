//
//  ServiceViewController.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 12/03/26.
//
import UIKit
import MapKit
import CoreLocation

class ServicesViewController: BaseViewController {
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var mapContainerView: UIView!
    
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCityOnMap(city: "Vancouver, BC", mapView: mapView)
     
        showMap()
        
    }
    
    
    
    @IBAction func listTapped(_ sender: UIButton) {
        showList()
    }

    @IBAction func mapTapped(_ sender: UIButton) {
        showMap()
    }
    
    func showList() {
        listView.isHidden = false
        mapContainerView.isHidden = true

        updateButtonUI(selected: listButton)
    }
    
    func showMap() {
        listView.isHidden = true
        mapContainerView.isHidden = false

        updateButtonUI(selected: mapButton)
    }
    
    func updateButtonUI(selected: UIButton) {

        let buttons = [listButton, mapButton]

        for btn in buttons {
            if btn == selected {
                btn?.backgroundColor = .white
              
            } else {
                btn?.backgroundColor = .clear
                
            }
        }
    }
    
    
    func showCityOnMap(city: String, mapView: MKMapView) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(city) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                print("City not found")
                return
            }
            
            // Center map on city with a tight zoom
            let region = MKCoordinateRegion(center: location.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            mapView.setRegion(region, animated: true)
            
            // Optional: add a pin
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
//            annotation.title = "Services near \(city)"
            mapView.addAnnotation(annotation)
        }
    }
    
}
