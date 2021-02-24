//
//  ViewController.swift
//  WeatherApp
//
//  Created by Pavel Shyker on 1/11/21.
//  Copyright © 2021 Pavel Shyker. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    var timer: Timer = Timer()
    var isLocationUpdated = false
    var citiesArray = [String]()
    lazy var locationCity: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startMonitoringLocation()
        citiesArray = UserDefaults.standard.value(forKey: "citiesArray") as? [String] ?? [String]()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func checkLocation() {
        if CLLocationManager.authorizationStatus().rawValue != 2 && CLLocationManager.locationServicesEnabled() && isLocationUpdated == false {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
                self.navigateToMainWeatherScreen()
            }
        }
        else if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus().rawValue == 2 {
            if citiesArray.isEmpty {
                locationCity = citiesArray.first ?? "-"
                navigateToAddCityButtonScreen()
            }
            else {
                let weatherStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let weatherViewController = weatherStoryBoard.instantiateViewController(withIdentifier: String(describing: MainWeatherViewController.self)) as? MainWeatherViewController
                navigationController?.pushViewController(weatherViewController ?? UIViewController(), animated: true)
                navigationController?.setNavigationBarHidden(true, animated: true)
                isLocationUpdated = true
            }
        }
    }
    
    public func navigateToMainWeatherScreen() {
        if !locationCity.isEmpty {
            timer.invalidate()
            let weatherStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let weatherViewController = weatherStoryBoard.instantiateViewController(withIdentifier: String(describing: MainWeatherViewController.self)) as? MainWeatherViewController
            navigationController?.pushViewController(weatherViewController ?? UIViewController(), animated: true)
            navigationController?.setNavigationBarHidden(true, animated: true)
            isLocationUpdated = true
        }
    }
    
    func navigateToAddCityButtonScreen() {
        let addCityButtonStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addCityButtonViewController = addCityButtonStoryboard.instantiateViewController(withIdentifier: String(describing: AddCityButtonViewController.self)) as? AddCityButtonViewController
        navigationController?.pushViewController(addCityButtonViewController ?? UIViewController(), animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func startMonitoringLocation() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            
            geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
                if let currentLocationPlacemark = placemarks?.first {
                    if let placemarkCity = currentLocationPlacemark.locality {
                        self.locationCity = placemarkCity
                        UserDefaults.standard.set(self.locationCity, forKey: "geoCity")
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.checkLocation()
        }
        if status == .denied {
            self.checkLocation()
        }
    }
}

