//
//  ViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/08.
//

import UIKit
import YumemiWeather


struct WeatherData: Codable {
    let maxTemperature: Int
    let date: String
    let minTemperature: Int
    let weatherCondition: String
    
    enum CodingKeys: String, CodingKey {
        case maxTemperature = "max_temperature"
        case date
        case minTemperature = "min_temperature"
        case weatherCondition = "weather_condition"
    }
}

struct WeatherRequest: Codable {
    let area: String
    let date: String
}

class SecondViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    
    @IBAction func closeButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toFirst", sender: self)
    }
    
       
    @IBAction func reloadButton(_ sender: Any) {
        do {
          guard let jsonString = encodeFetchWeatherParameter(area: "tokyo", date: Date()) else { return }
          let jsonStringWeather = try YumemiWeather.fetchWeather(jsonString)
          guard let weatherData = decodeFetchWeatherReturns(jsonString: jsonStringWeather) else { return }
          blueLabel.text = String(weatherData.minTemperature)
          redLabel.text = String(weatherData.maxTemperature)
          displayWeatherImage(weatherData.weatherCondition)
        } catch {
          displayErrorAlert()
        }
    }
    
    private func encodeFetchWeatherParameter(area: String, date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let dateString = dateFormatter.string(from: date)
        let request = WeatherRequest(area: area, date: dateString)
        let encoder = JSONEncoder()
        let jsonData = try? encoder.encode(request)
        return String(data:jsonData!,encoding: .utf8)!
    }
      

    private func decodeFetchWeatherReturns(jsonString: String) -> WeatherData?{
      guard let jsonData = jsonString.data(using: .utf8) else { return nil }
      guard let weatherData = try? JSONDecoder().decode(WeatherData.self, from: jsonData) else { return nil }
      return weatherData
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
        
    }
    
    private func displayWeatherImage(_ weatherCondition: String) {
        let imageName: String
        switch weatherCondition {
        case "cloudy":
            imageName = "iconmonstr-umbrella-1"
        case "rainy":
            imageName = "iconmonstr-weather-1"
        case "sunny":
            imageName = "iconmonstr-weather-11"
        default:
            imageName = ""
            print("未知の天気情報")
        }
        imageView.image = UIImage(named: imageName)
    }
    
    private func displayErrorAlert() {
        let alertController = UIAlertController(title: "エラー", message: "天気情報の取得に失敗しました。", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

