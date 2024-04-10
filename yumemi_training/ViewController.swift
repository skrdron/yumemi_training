//
//  ViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/08.
//

import UIKit
import YumemiWeather

//JSONデータ内のキー名とSwiftのプロパティ名をマッピング = キャメルケースに対応
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

//JSONデータ内のキー名とSwiftのプロパティ名をマッピング = キャメルケースに対応
//リクエストパラメータを定義
struct WeatherRequest: Codable {
    let area: String
    let date: String
}

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    
       
    @IBAction func reloadButton(_ sender: Any) {
        do {
          //地域と日付を指定してAPIリクエスト用のJSON文字列を生成 jsonStringに代入
          guard let jsonString = encodeFetchWeatherParameter(area: "tokyo", date: Date()) else { return }
          //生成したAPIリクエストを送信し、天気情報を取得。JSON形式の文字列としてjsonStringWeatherに代入
          let jsonStringWeather = try YumemiWeather.fetchWeather(jsonString)
          //取得した天気情報のJSON文字列をデコードし、WeatherDataオブジェクトに変換
          guard let weatherData = decodeFetchWeatherReturns(jsonString: jsonStringWeather) else { return }
          //最低気温と最高気温を取得し、それぞれ表示
          blueLabel.text = String(weatherData.minTemperature)
          redLabel.text = String(weatherData.maxTemperature)
          displayWeatherImage(weatherData.weatherCondition)
        } catch {
          displayErrorAlert()
        }
    }
    
    //天気情報の取得に必要なパラメータをエンコードしてJSON文字列に変換 = APIリクエストのボディ部分を準備する
    private func encodeFetchWeatherParameter(area: String, date: Date) -> String? {
        //日付を特定の形式の文字列に変換
        let dateFormatter = DateFormatter()
        //指定されたフォーマットの文字列に変換
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        //指定されたDateオブジェクトをISO 8601形式の文字列に変換 = APIリクエストに含める日付の文字列が作成
        let dateString = dateFormatter.string(from: date)
        //リクエストオブジェクトの作成
        let request = WeatherRequest(area: area, date: dateString)
        //JSONEncoderの新しいインスタンスを作成
        let encoder = JSONEncoder()
        //指定されたWeatherRequestオブジェクトをJSON形式にエンコードする処理を行う
        let jsonData = try? encoder.encode(request)
        //データをJSON文字列に変換したものを返す
        return String(data:jsonData!,encoding: .utf8)!
    }
      

    //JSON文字列をWeatherData構造体にデコード = アプリ内で使用するために、Swiftのオブジェクトに変換する
    private func decodeFetchWeatherReturns(jsonString: String) -> WeatherData?{
      //指定されたUTF-8エンコードの文字列からデータ型（Data）に変換
      guard let jsonData = jsonString.data(using: .utf8) else { return nil }
      //JSONDecoderを使用してデータをWeatherDataオブジェクトにデコード
      guard let weatherData = try? JSONDecoder().decode(WeatherData.self, from: jsonData) else { return nil }
      //WeatherDataオブジェクトを返す
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

