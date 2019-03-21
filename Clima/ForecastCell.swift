//
//  TableViewCell.swift
//  Clima
//
//  Created by Raj on 3/20/19.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

class ForecastCell: UITableViewCell {

    
    @IBOutlet weak var forecastDay: UILabel!
    @IBOutlet weak var forecastIcon: UIImageView!
    @IBOutlet weak var forecastMin: UILabel!
    @IBOutlet weak var forecastMax: UILabel!
    @IBOutlet weak var forecastHumidity: UILabel!
    @IBOutlet weak var forecastWindSpeed: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(_ val:[[String]]){
        //print(val)
//        forecastDay.text = val[0]["day"]
//        forecastIcon.image = UIImage(named: val[0]["icon"]!)
//        forecastMin.text = val[0]["min_temp"]
//        forecastMax.text = val[0]["max_temp"]
//        forecastHumidity.text = val[0]["humidity"]
//        forecastWindSpeed.text = val[0]["wind_speed"]
    }
}
