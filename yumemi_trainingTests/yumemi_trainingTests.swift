//
//  yumemi_trainingTests.swift
//  yumemi_trainingTests
//
//  Created by 櫻田龍之助 on 2024/04/08.
//

import XCTest
@testable import yumemi_training

final class yumemi_trainingTests: XCTestCase {
    
    //ビューコントローラ/クラスのインスタンスを保持するプロパティを定義
    var viewController: SecondViewController!
    var weatherProviderMock: WeatherProviderMock!
    
    override func setUp() {
        super.setUp()
        //テストを行うstoryboardを定義
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "SecondView") as? SecondViewController
        // テスト用にWeatherProviderのモックを作成し、ViewControllerに注入
        let weatherProviderMock = WeatherProviderMock()
        viewController.weatherProvider = weatherProviderMock
        viewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testDisplayWeatherImageForSunnyWeather() {
           // 期待される画像
           let expectedImage = "iconmonstr-weather-11"
           // テスト用の天気ダミーデータ
           let dummyWeatherData = WeatherData(
            maxTemperature: 30,
            date: "2024-04-12T12:00:00+09:00",
            minTemperature: 20,
            weatherCondition: "sunny"
           )
           //↑これらを使って表示してみる → 天気情報を設定、リロードボタンを呼び出したい
           viewController.weatherData = dummyWeatherData
           viewController.reloadButton(self)
           XCTAssertEqual(viewController.imageView.image, UIImage(named: expectedImage))
       }
}

// WeatherProviderクラスの振る舞いを模倣したテスト用のクラス = モッククラス
class WeatherProviderMock: WeatherFetching {
    func fetchWeather(_ request: WeatherRequest) throws -> WeatherData {
        // モックのデータを返す（sunny ver.）
        return WeatherData(
            maxTemperature: 30,
            date: "2024-04-12T12:00:00+09:00",
            minTemperature: 20,
            weatherCondition: "sunny"
        )
    }
}

