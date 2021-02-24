//
//  CitiesListViewController.swift
//  WeatherApp
//
//  Created by Pavel Shyker on 2/3/21.
//  Copyright © 2021 Pavel Shyker. All rights reserved.
//

import UIKit
import CoreLocation

class CitiesListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var citiesArray = [String]()
    var geoCity: String = "-"
    var selectedCity: String = ""
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        geoCity = UserDefaults.standard.value(forKey: "geoCity") as? String ?? "Location is not recognized"
        citiesArray = UserDefaults.standard.value(forKey: "citiesArray") as? [String] ?? [String]()
        
        // Do any additional setup after loading the view.
    }

    func navigateToMainWeatherScreen() {
            let weatherStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let weatherViewController = weatherStoryBoard.instantiateViewController(withIdentifier: String(describing: MainWeatherViewController.self)) as? MainWeatherViewController
            navigationController?.pushViewController(weatherViewController ?? UIViewController(), animated: true)
            navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func addCityButtonTapped(_ sender: Any) {
        let settingsStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsViewController = settingsStoryboard.instantiateViewController(withIdentifier: String(describing: CitySettingViewController.self)) as? CitySettingViewController
        navigationController?.pushViewController(settingsViewController ?? UIViewController(), animated: true)
    }
}

extension CitiesListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let myLocationTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: MyLocationTableViewCell.self), for: indexPath) as? MyLocationTableViewCell
                else {
                    return UITableViewCell()
            }
            if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus().rawValue == 2 {
               myLocationTableViewCell.geoCityLabel.text = "Location is not recognized"
                }
            else {
            myLocationTableViewCell.geoCityLabel.text = geoCity
            }
            return myLocationTableViewCell
        }
            
        else if indexPath.row == citiesArray.count + 1 {
            guard let addCityTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddCityTableViewCell.self), for: indexPath) as? AddCityTableViewCell
                else {
                    return UITableViewCell()
            }
            return addCityTableViewCell
        }
            
        else {
           guard let addedCityTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddedCityTableViewCell.self), for: indexPath) as? AddedCityTableViewCell
            else {
                return UITableViewCell()
            }
            addedCityTableViewCell.addedCity.text = citiesArray[indexPath.row - 1]
            return addedCityTableViewCell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= 1 && indexPath.row <= citiesArray.count {
            selectedCity = citiesArray[indexPath.row - 1]
            UserDefaults.standard.set(selectedCity, forKey: "selectedCity")
            UserDefaults.standard.set(true, forKey: "isUpdateNeeded")
            navigateToMainWeatherScreen()
            print(selectedCity)
        }
        else if indexPath.row == 0 && (CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus().rawValue != 2) {
            UserDefaults.standard.set(geoCity, forKey: "selectedCity")
            navigateToMainWeatherScreen()
        }
    }
}
