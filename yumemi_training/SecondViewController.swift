//
//  ViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/08.
//

import UIKit

class SecondViewController: UIViewController{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    
    var weatherData: WeatherData?
    
    override func viewDidLoad() {
      super.viewDidLoad()
      updateUI()
    }
    
    private func updateUI() {
      guard let data = weatherData else { return }
      blueLabel.text = "\(data.info.minTemperature)℃"
      redLabel.text = "\(data.info.maxTemperature)℃"
      let imageName = displayWeatherImage(data.info.weatherCondition)
      imageView.image = UIImage(named: imageName)
      self.title = data.area
    }
    
    private func displayWeatherImage(_ weatherCondition: String) -> String {
        switch weatherCondition {
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
