//
//  MapManager.swift
//  testTableViewAppMyPlaces
//
//  Created by Алексей Черанёв on 04.08.2021.
//

import UIKit
import MapKit

class MapManager {
    var locationManager = CLLocationManager()
    
    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionInMeteres = 1_000.0
    private var directionsArray: [MKDirections] = []
    
    //Placemark of company
    func setupPlaceMark(place: Place, mapView: MKMapView) {
        guard let location = place.location else {
            return
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placeMarkLocation = placemark?.location else { return }
            annotation.coordinate = placeMarkLocation.coordinate
            self.placeCoordinate = placeMarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    //Checking the availability of geolocation services
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        }
        else
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your location is not available",
                               message: "To give permission go to settings -> testTableViewAppMyPlaces -> Location services and turn on")
            }
        }
    }
    
    //Checking the application authorization for using geolocation services
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        switch locationManager.authorizationStatus {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your location is not available",
                               message: "To give permission go to settings -> testTableViewAppMyPlaces -> Location")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //Show alert controller
            break
        @unknown default:
            print("New case is available")
        }
    }
    //Focusing the map on user's location
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate
        {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeteres,
                                            longitudinalMeters: regionInMeteres)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //Making a route from the user's location to the organization
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        
        resetMapView(mapView: mapView, withNew: directions)
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }
            
            for route in response.routes
            {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distance) км.")
                print("Время в пути: \(timeInterval) c.")
            }
        }
        
    }
    
    //Configuring a request for route calculation
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate  else {
            return nil
        }
        let startingLocation =  MKPlacemark(coordinate: coordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        return request
    }
    
    //Changing the displayed area of the map in accordance with the user's movement
    func startTrackingUserLocation(mapView: MKMapView, location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else {
            return
        }
        let center =  getCenterLocation(for: mapView)
        
        guard center.distance(from: location) > 50 else {
            return
        }
        
        closure(center)
    }
    
    //Reseting all previously created routes before making a new one
    func resetMapView(mapView: MKMapView, withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {  $0.cancel() }
        directionsArray.removeAll()
    }
    
    //Determining the center of the displayed area
    func getCenterLocation(for mapView: MKMapView) -> CLLocation
    {
        let lattitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: lattitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
    
    
}
