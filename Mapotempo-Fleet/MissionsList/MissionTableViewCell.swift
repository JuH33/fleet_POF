//
//  MissionTableViewCell.swift
//  Mapotempo-Fleet
//
//  Created by julien boyer on 27/04/2018.
//  Copyright © 2018 julien boyer. All rights reserved.
//

import UIKit

class MissionTableViewCell: UITableViewCell {

    @IBOutlet weak var missionName: UILabel!
    @IBOutlet weak var missionDsc: UILabel!
    @IBOutlet weak var statusBackground: UIView!
    @IBOutlet weak var statusIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
