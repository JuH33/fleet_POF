//
//  MapViewController.swift
//  Mapotempo-Fleet
//
//  Created by julien boyer on 27/04/2018.
//  Copyright © 2018 julien boyer. All rights reserved.
//

import UIKit
import Mapbox

class MapViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {

    //MARK: Properties
    private var mapView: MGLMapView!
    private let locationManager = CLLocationManager()
    private var userPosition: MGLPointAnnotation?
    
    public var missions: [IMission]?
    public var editMode: Bool = false
    public var onAnnotationCreated: ((_ mapView: MGLMapView, _ position: CLLocationCoordinate2D) -> ())?
    private var newLocationPoint: MGLPointAnnotation?
    public var locationPointCoordinates: CLLocationCoordinate2D? {
        didSet {
            editNewLocation(coords: locationPointCoordinates!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 44.836151, longitude: -0.580816), zoomLevel: 12, animated: false)
        mapView.styleURL = Constants.MapConf.style
        mapView.delegate = self
        
        view.addSubview(mapView)
        startReceivingLocationChanges()
        
        if editMode {
            let mapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGesture))
            mapView.addGestureRecognizer(mapGesture)
            
            // CREATE A SAVE BUTTON
            let sysItem = UIBarButtonSystemItem(rawValue: 3) // 3 is for < save >
            let btn = UIBarButtonItem(barButtonSystemItem: sysItem!, target: self, action: #selector(saveAction))
            self.navigationItem.rightBarButtonItem = btn
        }
    }
    
    @objc func saveAction() {
        if newLocationPoint == nil {return}
        if let edit = navigationController!.childViewControllers.first as? MissionDetailEditController {
            edit.location = newLocationPoint?.coordinate
            backBtnAction(self.navigationItem.rightBarButtonItem!)
        }
    }
    
    @objc func onTapGesture(sender: UITapGestureRecognizer) {
        let point: CGPoint = sender.location(in: mapView)
        let coords: CLLocationCoordinate2D = mapView.convert(point, toCoordinateFrom: mapView)
        editNewLocation(coords: coords)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IActions
    @IBAction func backBtnAction(_ sender: UIBarButtonItem) {
        if let navCount = navigationController?.childViewControllers.count, navCount > 1 {
            navigationController!.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: Mapbox functions
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        if let missionsAsAnnotations = missions {
            missionsLocation(missionsAsAnnotations)
        }
    }
    
    // Allow callout view to appear when an annotation is tapped.
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    // Center the camera when user tap on an annotation
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let mapCoords = CLLocationCoordinate2D.init(latitude: mapView.centerCoordinate.latitude,
                                                    longitude: mapView.centerCoordinate.longitude)
        if distanceBetweenUnderEpsilon(annotation.coordinate, mapCoords) {
            return
        }
        self.camera(centerTo: annotation.coordinate, distance: nil, pitch: nil, heading: nil)
    }
    
    //MARK: Private Helpers
    
    // Use Epsilone Double to respond with an Boolean if coordinates are close
    func distanceBetweenUnderEpsilon(_ loc1: CLLocationCoordinate2D, _ loc2: CLLocationCoordinate2D) -> Bool {
        return (loc1.latitude - loc2.latitude) <= Double.ulpOfOne &&
               (loc1.longitude - loc2.longitude) <= Double.ulpOfOne
    }
    
    func editNewLocation(coords: CLLocationCoordinate2D) -> Void {
        if newLocationPoint != nil { mapView.removeAnnotation(newLocationPoint!) }
        
        newLocationPoint = MGLPointAnnotation()
        newLocationPoint!.coordinate = coords
        mapView.addAnnotation(newLocationPoint!)
        
        camera(centerTo: coords, distance: nil, pitch: nil, heading: nil)
    }
    
    //MARK: Missions Factory
    func missionsLocation(_ missionsAnnotations: [IMission]) -> Void {
        var missionsAsDisplay: [MGLPointAnnotation] = [MGLPointAnnotation]()
        for mission in missionsAnnotations {
            if !mission.hasValidCoords() {
                continue
            }
            
            let point = MGLPointAnnotation()
            let location = mission.getLocation()
            point.coordinate = CLLocationCoordinate2D(latitude: location!.lat, longitude: location!.lng)
            point.title = mission.getName()
            
            onAnnotationCreated?(mapView!, point.coordinate)
            missionsAsDisplay.append(point)
        }
        
        mapView.addAnnotations(missionsAsDisplay)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? MissionDetailEditController {
            dest.location = newLocationPoint?.coordinate
        }
    }
    
    func camera(centerTo: CLLocationCoordinate2D?, distance: Int?, pitch: CGFloat?, heading: Int?) -> Void {
        if mapView == nil {return}
        
        let _centerTo = centerTo != nil ? centerTo! : CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let dist = distance != nil ? distance! : 4000
        let _pitch = pitch != nil ? pitch! : 0
        let _heading = heading != nil ? heading! : 0
        
        let camera = MGLMapCamera(lookingAtCenter: _centerTo,
                                  fromDistance: CLLocationDistance(dist),
                                  pitch: _pitch,
                                  heading: CLLocationDirection(_heading))
        
        mapView.setCamera(camera, animated: true)
    }
}

//MARK: Location Manager Callbacks Extension -----------

extension MapViewController {
    
    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            return
        }
        
        if !CLLocationManager.locationServicesEnabled() {
            return
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100.0
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count <= 0 {
            return
        }
        
        if let coords: CLLocationCoordinate2D = locations.last?.coordinate {
            userPosition = MGLPointAnnotation()
            userPosition!.coordinate = coords
            userPosition!.title = "Your position"
            
            mapView.addAnnotation(userPosition!)
        }
    }
    
}
