//
//  ViewController.swift
//  Mapotempo-Fleet
//
//  Created by julien boyer on 27/04/2018.
//  Copyright © 2018 julien boyer. All rights reserved.
//

import UIKit
import Mapbox

class MissionDetailController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var missionName: UILabel!
    @IBOutlet weak var missionStatusBtn: UIButton!
    @IBOutlet weak var missionAddress: UILabel!
    @IBOutlet weak var missionPlannedAt: UILabel!
    @IBOutlet weak var missionDescription: UILabel!
    @IBOutlet weak var missionPhoneNumber: UILabel!
    
    //MARK: Properties
    var mission: IMission?
    var onViewClose: ((_ mission: IMission) -> Void)?
    
    @IBAction func onClickStatus(_ sender: UIButton) {
        let nextState = mission!.nextStatus()
        missionStatusBtn.setTitle(nextState.rawValue, for: .normal)
        missionStatusBtn.backgroundColor = UIColor(named: nextState.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mission != nil {
            missionName.text = mission!.getName()
            missionAddress.text = mission!.getAddress()
            missionDescription.text = mission!.getDescription()
            missionPhoneNumber.text = mission!.getPhoneNumber()
            missionPlannedAt.text = mission!.getDate()
            missionStatusBtn.backgroundColor = UIColor(named: mission!.getStatus()!)
            missionStatusBtn.setTitle(mission!.getStatus()!, for: .normal)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        onViewClose?(mission!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            case is MapViewController:
                    let mapCtrl = segue.destination as! MapViewController
                    mapCtrl.missions = [self.mission!]
                    
                    // Callback passed to the map controller after map has been init async'
                    mapCtrl.onAnnotationCreated = { (_ mapView: MGLMapView, _ position: CLLocationCoordinate2D) in
                        mapCtrl.camera(centerTo: position, distance: nil, pitch: nil, heading: nil)
                    }
                    break
            case is MissionsListController:
                
                break
            default:
                break
        }
    }

}

