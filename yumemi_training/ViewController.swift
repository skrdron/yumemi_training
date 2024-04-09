//
//  ViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/08.
//

import UIKit
import YumemiWeather

struct WeatherData: Codable {
    let max_temperature: Int
    let date: String
    let min_temperature: Int
    let weather_condition: String
}

struct Request:Encodable{
    let area:String
    let date:String
}

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    
       
    @IBAction func reloadButton(_ sender: Any) {
        print("ボタンがクリックされました")
        do {
          guard let jsonString = encodeFetchWeatherParameter(area: "tokyo", date: Date()) else { return }
          let jsonStringWeather = try YumemiWeather.fetchWeather(jsonString)
            guard let weatherData = decodeFetchWeatherReturns(jsonString: jsonStringWeather) else {
                return print("リターンされました")
            }
          blueLabel.text = String(weatherData.min_temperature)
          redLabel.text = String(weatherData.max_temperature)
          displayWeatherImage(weatherData.weather_condition)
        } catch {
          print(error)
          displayErrorAlert()
        }
    }
    
    
    private func encodeFetchWeatherParameter(area: String, date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let dateString = dateFormatter.string(from: date)
        let request = Request(area: area, date: dateString)
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
            print("Unknown weather condition")
        }
        imageView.image = UIImage(named: imageName)
    }
    
    private func displayErrorAlert() {
        let alertController = UIAlertController(title: "エラー", message: "天気情報の取得に失敗しました。", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

