//
//  MissionDetailUpdateController.swift
//  Mapotempo-Fleet
//
//  Created by julien boyer on 17/05/2018.
//  Copyright © 2018 julien boyer. All rights reserved.
//

import UIKit
import Mapbox
import Toaster
import MapboxGeocoder

class MissionDetailEditController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var phoneInput: UITextField!
    @IBOutlet weak var descInput: UITextField!
    @IBOutlet weak var datePickerInput: UIDatePicker!
    
    private weak var mapContainer: MapViewController?
    
    // MARK: Properties
    public var mMission: IMission?
    public var location: CLLocationCoordinate2D? {
        didSet {
            if mapContainer != nil {
                mapContainer!.locationPointCoordinates = location
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Mission Edition"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameInput.resignFirstResponder()
        phoneInput.resignFirstResponder()
        descInput.resignFirstResponder()
        datePickerInput.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func exitAction(_ sender: Any) {
        if self.navigationController != nil {
            self.performSegue(withIdentifier: Constants.MissionDetail.LIST_UNWIND, sender: self)
        }
    }
    
    private func isValidMission() -> Bool {
        var isValid = true
        
        if let tel = phoneInput.text {
            let phonePattern = "^[0-9]{10}$"
            let phoneRegex = try? NSRegularExpression(pattern: phonePattern, options: [])
            let matches = phoneRegex?.matches(in: tel, options: [], range: NSRange(location: 0, length: tel.count))
            isValid = (matches?.count == 1)
        }
        
        isValid = isValid && (nameInput.text!.count > 0 && location != nil
            && descInput.text != nil && descInput.text!.count > 0)
        
        return isValid
    }

    // MARK: - Navigation
    
    @IBAction func saveAction(_ sender: UIButton) {
        ToastView.appearance().backgroundColor = UIColor(named: "Error")
        ToastView.appearance().bottomOffsetPortrait = 125
        
        if  !isValidMission() {
            self.mMission = nil
            Toast.init(text: "Mission is invalid", delay: 0, duration: 5).show()
            return
        }
            
        let db = CouchbaseWrapper.GetInstance()
        var mission = db.missionAccess().createMission()
        
        mission.property(forKey: MDbKeys.NAME.rawValue, value: nameInput.text)
        mission.property(forKey: MDbKeys.DESCRIPTION.rawValue, value: descInput.text)
        mission.property(forKey: MDbKeys.PHONE.rawValue, value: phoneInput.text)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US")
        
        mission.property(forKey: MDbKeys.DATE.rawValue,
                         value: dateFormatter.string(from: datePickerInput.date))
        
        let loc = MissionCouchbase.Location.init(lat: location?.latitude ?? 0,
                                                 lng: location?.longitude ?? 0)
        mission.property(forKey: MDbKeys.LOCATION.rawValue, value: loc)
        
        let geocoder = Geocoder.shared
        let options = ReverseGeocodeOptions(coordinate: location!)
        
        // THREADED OPERATION
        _ = geocoder.geocode(options) { (placemarks, attribution, error) in
            guard let placemark = placemarks?.first else {
                return
            }
            
            let region = placemark.administrativeRegion?.name ?? ""
            let street = placemark.qualifiedName ?? ""
            
            let address: String = region + ", " + street
            mission.property(forKey: MDbKeys.ADDRESS.rawValue, value: address)
            
            do {
                try mission.save()
                self.mMission = mission
            } catch {
                Toast.init(text: "Mission hasn't been saved \(error)",
                    delay: Delay.short, duration: Delay.long).show()
                print(error)
            }
            
            self.performSegue(withIdentifier: Constants.MissionDetail.LIST_UNWIND, sender: self)
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case is MissionsListController:
            if mMission != nil {
                let listController = segue.destination as! MissionsListController
                listController.addMissions([mMission!])
            }
            break
        case is MissionDetailController:
            // PROCEED TO UPDATE
            break
        case is MapViewController:
            let mapController = segue.destination as! MapViewController
            
            if segue.identifier == "embedMap" {
                mapContainer = mapController
                mapController.camera(centerTo: location, distance: nil, pitch: nil, heading: nil)
                return
            }
            
            mapController.editMode = true
            break
        default:
            break
        }
    }

}
