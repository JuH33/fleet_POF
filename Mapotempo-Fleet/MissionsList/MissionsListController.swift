//
//  MissionsListController.swift
//  Mapotempo-Fleet
//
//  Created by julien boyer on 27/04/2018.
//  Copyright © 2018 julien boyer. All rights reserved.
//

import UIKit
import Toaster

class MissionsListController: UITableViewController {
    
    var missionList: [IMission] = [IMission]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let wrapper = CouchbaseWrapper.GetInstance()
        let missionAccess = wrapper.missionAccess()
        missionList = missionAccess.getMissions()
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return missionList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = "TableViewCell"
        
        guard let view = tableView.dequeueReusableCell(withIdentifier: index) as? MissionTableViewCell else {
            fatalError("wrong cell selected")
        }

        let mission: IMission = missionList[indexPath.row]
        view.missionName.text = mission.getName()
        view.missionDsc.text = mission.getDescription()
        view.statusIcon.image = UIImage(named: mission.getStatus()! + "Icon")
        view.statusBackground.backgroundColor = UIColor(named: mission.getStatus()!)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let mission = missionList[indexPath.row]
            do {
                try mission.delete()
                missionList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: Public
    
    func addMissions(_ missions: [IMission]) -> Void {
        let indexpath = IndexPath(row: missionList.count, section: 0)
        missionList.append(contentsOf: missions)
        tableView.insertRows(at: [indexpath], with: .automatic)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowDetail":
            guard let detailController = segue.destination as? MissionDetailController else {
                fatalError("Wrong seed required or duplicate identifier detected")
            }
            
            guard let view = sender as? MissionTableViewCell else {
                fatalError("Item from table view isn't well parametred")
            }
            
            let index = tableView.indexPath(for: view)!
            detailController.mission = missionList[index.row]
            
            detailController.onViewClose = { (_ mission: IMission) -> Void in
                if mission.getStatus()! == self.missionList[index.row].getStatus()! { return }
                
                self.missionList[index.row] = mission
                self.tableView.reloadRows(at: [index], with: .fade)
                mission.update()
                
                ToastView.appearance().backgroundColor = UIColor(named: mission.getStatus()!)
                Toast.init(text: "Status Updated", delay: 0, duration: Delay.short).show()
            }
            break
        case "ShowMap":
            guard let nav = segue.destination as? UINavigationController,
                  let mapDetail = nav.topViewController as? MapViewController else {
                fatalError("Wrong seguge requested")
            }
            mapDetail.missions = missionList
            break
        default:
            //fatalError("segue not referenced")
            break
        }
    }
    
    @IBAction func unwindToList(segue: UIStoryboardSegue) {
        
    }

}
