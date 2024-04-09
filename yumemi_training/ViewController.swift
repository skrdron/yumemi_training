//
//  ViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/08.
//

import UIKit
import YumemiWeather

//JsonからObject(struct)へ変換 これらを表示する
struct WeatherData: Codable {
    let area: String
    let info: WeatherInfo
}

struct WeatherInfo: Codable {
    let max_temperature: Int
    let date: String
    let min_temperature: Int
    let weather_condition: String
}

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var BlueLabel:UILabel!
    @IBOutlet weak var RedLabel:UILabel!
       
    @IBAction func reloadButton(_ sender: Any) {
        do {
          // 指定された地域と日付を含むJSON文字列を作成
          guard let jsonString = encodeFetchWeatherParameter(area: "Tokyo", date: Date()) else { return }
          // 作成されたJSON文字列を使って天気情報のJSON文字列を取得
          let jsonStringWeather = try YumemiWeather.fetchWeather(jsonString)
          // 取得した天気情報のJSON文字列をパースし、WeatherData Structにデコード
          guard let weatherData = decodeFetchWeatherReturns(jsonString: jsonStringWeather) else { return }
          // パースされた天気情報を元に、最高気温と最低気温をBlueLabelとRedLabelに表示
          BlueLabel.text = String(weatherData.info.min_temperature)
          RedLabel.text = String(weatherData.info.max_temperature)
          //天気情報をもとにImageに表示
          displayWeatherImage(weatherData.info.weather_condition)
        } catch {
          print(error)
          displayErrorAlert()
        }
    }
    
    
     //指定された地域と日付を含むJSON文字列を生成する
     private func encodeFetchWeatherParameter(area: String, date: Date) -> String? {
          let dateFormatter = ISO8601DateFormatter()
          dateFormatter.formatOptions = [.withFullDate, .withTime, .withTimeZone, .withColonSeparatorInTimeZone]
          let dateString = dateFormatter.string(from: date)
         //地域と日付が含まれたJSON文字列を返す
          return """
          {
              "area": "\(area)",
              "date": "\(dateString)"
          }
          """
      }
      
    //天気情報のJSON文字列をWeatherData構造体にデコードする役割
    private func decodeFetchWeatherReturns(jsonString: String) -> WeatherData?{
      guard let jsonData = jsonString.data(using: .utf8) else { return nil }
      guard let weatherData = try? JSONDecoder().decode([WeatherData].self, from: jsonData).first else { return nil }
      //デコードされたWeatherData構造体を返す
      return weatherData
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.
        
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

