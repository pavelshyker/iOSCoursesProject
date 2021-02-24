//
//  MyLocationTableViewCell.swift
//  WeatherApp
//
//  Created by Pavel Shyker on 2/3/21.
//  Copyright © 2021 Pavel Shyker. All rights reserved.
//

import UIKit

class MyLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var geoCityLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
