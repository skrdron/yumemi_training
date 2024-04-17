//
//  ViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/08.
//

import UIKit
import YumemiWeather
import CoreLocation


protocol WeatherFetching {
    func fetchWeather(_ request: WeatherRequest) async throws -> WeatherData
}

public class WeatherProvider:WeatherFetching{
    func fetchWeather(_ request: WeatherRequest) async throws -> WeatherData {
        _ = encodeFetchWeatherParameter(area: request.area, date: Date())
        //APIの結果を、コンカレンシー形式で受け取るように変更したい
        let jsonData = try JSONEncoder().encode(request)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        let result = try await YumemiWeather.asyncFetchWeather(jsonString)
        guard let weatherData = decodeFetchWeatherReturns(jsonString: result) else{
            throw WeatherProviderError.decodingError
        }
        return weatherData
    }
    
    enum WeatherProviderError: Error {
        case decodingError
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
}


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


class SecondViewController: UIViewController, CLLocationManagerDelegate {
    public var weatherProvider: WeatherFetching
    public var weatherData: WeatherData?
    
    init?(coder: NSCoder,weatherProvider: WeatherFetching) {
      self.weatherProvider = weatherProvider
      super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
      fatalError("想定しないエラーが発生したためプログラムを終了します。")
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    
    @IBAction func closeButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toFirst", sender: self)
    }
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
       
    @IBAction func reloadButton(_ sender: Any) {
        Task {
          activityIndicatorView.isHidden = true
          activityIndicatorView.stopAnimating()
          do {
            let request = WeatherRequest(area: "tokyo", date: formattedDateString(Date()))
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
            let weatherData = try await weatherProvider.fetchWeather(request)
            updateUIWithWeatherData(weatherData)
            activityIndicatorView.isHidden = true
          } catch {
            displayErrorAlert("天気情報取得に失敗しました")
          }
                
        }
    }
    
    
    private func formattedDateString(_ date: Date) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      return dateFormatter.string(from: date)
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      activityIndicatorView.isHidden = true
    }
    
    private func updateUIWithWeatherData(_ weatherData: WeatherData) {
          blueLabel.text = String(weatherData.minTemperature)
          redLabel.text = String(weatherData.maxTemperature)
          displayWeatherImage(weatherData.weatherCondition)
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
            print("無効な天気情報")
        }
        imageView.image = UIImage(named: imageName)
    }
    
    private func displayErrorAlert(_ message: String) {
        let alertController = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func addObserverForAppWillEnterForeground() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateWeatherData),
        name: UIApplication.willEnterForegroundNotification, object: nil)
    }
       
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        print("SecondViewControllerが解放されています")
    }
       
    @objc func updateWeatherData() {
        print("天気情報をアップデート")
        reloadButton(self)
    }
}



