//
//  ListTableViewCell.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/18.
//

import UIKit

class ListTableViewCell:UITableViewCell{
    @IBOutlet weak var area: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var minTemperature: UILabel!
    @IBOutlet weak var maxTemperature: UILabel!
    
    //カスタムテーブルビューセルに天気データを設定する
    func configure(with data: WeatherData) {
        area.text = "Tokyo"
        minTemperature.text = "\(data.info.minTemperature)℃"
        maxTemperature.text = "\(data.info.maxTemperature)℃"
        weatherImage.image = UIImage(named: imageName(forCondition: data.info.weatherCondition))
    }
    
    private func imageName(forCondition condition: String) -> String {
        switch condition {
          case "cloudy":
            return "iconmonstr-umbrella-1"
          case "rainy":
            return "iconmonstr-weather-1"
          case "sunny":
            return "iconmonstr-weather-11"
          default:
            print("無効な天気情報")
            return "" 
        }
    }
}




