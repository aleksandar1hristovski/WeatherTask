//
//  FavoritesTableViewCell.swift
//  WeatherTask
//
//  Created by Aleksandar Hristovski on 10.12.23.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {

    static let identifier = "FavoritesTableViewCell"
    
    static func nib()-> UINib{
        return UINib(nibName: "FavoritesTableViewCell", bundle: nil)
    }
    
    public func configure(cityName:String){
        cityLabel.text = cityName
    }
    
    @IBOutlet weak var cityLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
