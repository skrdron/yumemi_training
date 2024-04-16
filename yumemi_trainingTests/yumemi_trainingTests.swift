//
//  yumemi_trainingTests.swift
//  yumemi_trainingTests
//
//  Created by 櫻田龍之助 on 2024/04/08.
//

import XCTest
@testable import yumemi_training

final class yumemi_trainingTests: XCTestCase {
    
    // ビューコントローラ/クラスのインスタンスを保持するプロパティを定義
        var viewController: SecondViewController!
        var weatherProviderMock: WeatherProviderMock!
        
        override func setUp() {
            super.setUp()
            
            // テストを行うstoryboardを定義
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // WeatherProviderのモックを作成
            weatherProviderMock = WeatherProviderMock()
            
            // viewControllerを初期化し、weatherProviderにモックを注入
            viewController = storyboard.instantiateViewController(identifier: "SecondView") { coder in
                SecondViewController(coder: coder, weatherProvider: self.weatherProviderMock)
            }
            
            viewController.loadViewIfNeeded()
        }
        
        override func tearDown() {
            viewController = nil
            super.tearDown()
        }
        
        func testWeatherDataDisplayedInLabels() {
            // モックの天気データ
            let testData = WeatherData(maxTemperature: 25, date: "2024-04-15T12:00:00+09:00", minTemperature: 15, weatherCondition: "sunny")
            weatherProviderMock.mockedWeatherData = testData
            
            // 天気情報を更新
            viewController.reloadButton(self)
            
            // 非同期処理の完了を待つexpectation
            let expectation = XCTestExpectation(description: "天気情報がロードされた")
               
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // UILabelに最低気温と最高気温が表示されているか比較する
                XCTAssertEqual(self.viewController.blueLabel.text, "\(testData.minTemperature)")
                XCTAssertEqual(self.viewController.redLabel.text, "\(testData.maxTemperature)")
                   
                // expectationをfulfillしてテスト完了を通知
                expectation.fulfill()
            }
               
            // expectationがfulfillされるまで待機
            wait(for: [expectation], timeout: 2)
        }
        
        func testDisplayWeatherImageForWeatherCondition() {
            // テスト用のデータ
            let testData: [(condition: String, expectedImage: String)] = [
                ("sunny", "iconmonstr-weather-11"),
                ("cloudy", "iconmonstr-umbrella-1"),
                ("rainy", "iconmonstr-weather-1")
            ]
            
            for data in testData {
                // モックの天気データ
                weatherProviderMock.mockedWeatherData = WeatherData(
                    maxTemperature: 30,
                    date: "2024-04-12T12:00:00+09:00",
                    minTemperature: 20,
                    weatherCondition: data.condition
                )
                
                // 天気情報を更新
                viewController.reloadButton(self)
                
                // 非同期処理の完了を待つexpectation
                let expectation = XCTestExpectation(description: "天気イメージがロードされた")
                       
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // 期待される画像と実際の画像を比較する
                  XCTAssertEqual(self.viewController.imageView.image, UIImage(named: data.expectedImage))
                           
                  // expectationをfulfillしてテスト完了を通知
                  expectation.fulfill()
                }
                       
                // expectationがfulfillされるまで待機
                wait(for: [expectation], timeout: 2)
            }
        }
    }

// テスト用のWeatherProviderクラスのモック
class WeatherProviderMock: WeatherFetching {
    var mockedWeatherData: WeatherData?
    var mockedError: Error?
    
    func fetchWeather(_ request: WeatherRequest, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        if let data = mockedWeatherData {
            completion(.success(data))
        } else if let error = mockedError {
            completion(.failure(error))
        } else {
            fatalError("モックデータまたはモックエラーがセットされていません")
        }
    }
}
