//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var seacrhTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
        seacrhTextField.delegate = self
    }

}

// UITextDelegate
extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchButton(_ sender: UIButton) {
        seacrhTextField.endEditing(true) //buat nutup keyboard
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        seacrhTextField.endEditing(true) //buat nutup keyboard
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = seacrhTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        seacrhTextField.text = "" // untuk menghapus text search
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "wajib isi"
            return false
        }
    }
}

// WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
