//
//  MainWeatherViewController.swift
//  WeatherApp
//
//  Created by Pavel Shyker on 2/1/21.
//  Copyright © 2021 Pavel Shyker. All rights reserved.
//

import UIKit

class MainWeatherViewController: UIViewController {

    var citiesArray = [String]()
    lazy var city: String = "-"
    lazy var temp: Double = 0
    lazy var weatherDescription = "-"
    lazy var iconName = "01d"
    lazy var humidity = 0
    lazy var tempFeelsLike : Int = 0
    lazy var pressure = 0
    lazy var cityFromTheTable: String = ""
    var sunriseTime: String = "00:00"
    var sunsetTime: String = "00:00"
    var isUpdateNeeded: Bool = false
    var detailsInfo = ["", "", "", "", ""]
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var detailInfoButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var blurUiView: UIView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var detailInfoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailInfoTableView.delegate = self
        detailInfoTableView.dataSource = self
        
        citiesArray = UserDefaults.standard.value(forKey: "citiesArray") as? [String] ?? [String]()
        cityFromTheTable = UserDefaults.standard.value(forKey: "selectedCity") as? String ?? ""
        
        if let geoCity = UserDefaults.standard.value(forKey: "geoCity") as? String {
            city = geoCity
        }
        else {
            if !citiesArray.isEmpty {
                city = citiesArray.first ?? "-"
            }
        }
        updateWeatherData(city)
        detailDescriptionLabel.layer.cornerRadius = detailDescriptionLabel.frame.height/4
        detailDescriptionLabel.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        isUpdateNeeded = UserDefaults.standard.value(forKey: "isUpdateNeeded") as? Bool ?? false
        print ("uuu \(isUpdateNeeded)")
        if isUpdateNeeded == true {
            city = UserDefaults.standard.value(forKey: "selectedCity") as? String ?? "-"
            print ("uuu \(city)")
           updateWeatherData(city)
            UserDefaults.standard.set(false, forKey: "isUpdateNeeded")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cityLabel.text = city.uppercased()
        degreeLabel.text = String(Int(self.temp)) + "°C"
        imageView.image = UIImage(named: iconName)
        weatherDescriptionLabel.text = weatherDescription.uppercased()
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        let menuStiryBoard = UIStoryboard(name: "Main", bundle: nil)
        let menuViewController = menuStiryBoard.instantiateViewController(withIdentifier: String(describing: CitiesListViewController.self)) as? CitiesListViewController
        navigationController?.pushViewController(menuViewController ?? UIViewController(), animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func detilaInfoButtonTapped(_ sender: Any) {
        detailDescriptionLabel.text = "Current weather: \(weatherDescription)"
        animateBlur() 
    }
    
    func animateBlur() {
        UIView.animate(withDuration: 0.2, animations: {
            if self.blurView.alpha == 0 {
                self.blurView.alpha = 1
            }
            else {
                self.blurView.alpha = 0
            }
        })
    }
    
    func updateWeatherData(_ city: String) {
            let modifiedCityName = city.replacingOccurrences(of: " ", with: "%20")
            
            let urlString = "http://api.openweathermap.org/data/2.5/weather?q=\(modifiedCityName)&units=metric&appid=d43387d585d6c819d788f05ee55d9b5c"
            if let url = URL(string: urlString) {
                let urlRequest = URLRequest(url: url)
                let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                    guard error == nil else {
                        print(error?.localizedDescription ?? "somethong wrong")
                        return
                    }
                    if let data = data {
                        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                            //print (json)
                            let responseDict = json as? [String: Any]
                            
                            let main = responseDict?["main"] as? [String: Any]
                            self.temp = main?["temp"] as? Double ?? 0
                            
                            let weatherValues = responseDict?["weather"] as? [[String: Any]]
                            let weather = weatherValues?.first
                            self.weatherDescription = weather?["description"] as? String ?? "-"
                            self.iconName = weather?["icon"] as? String ?? "-"
                            
                            self.humidity = main?["humidity"] as? Int ?? 0
                            self.tempFeelsLike = main?["feels_like"] as? Int ?? 0
                            self.pressure = main?["pressure"] as? Int ?? 0
                            
                            let system = responseDict?["sys"] as? [String: Any]
                            let sunrise = system?["sunrise"] as? Double
                            let sunset = system?["sunset"] as? Double
                            let sunriseDate = Date(timeIntervalSince1970: sunrise ?? 0)
                            let sunsetDate = Date(timeIntervalSince1970: sunset ?? 0)
                            
                            let secondsFromGMT = responseDict?["timezone"] as? Int
                            
                            let dateFomater = DateFormatter()
                            dateFomater.timeZone = TimeZone(secondsFromGMT: secondsFromGMT ?? 0)
                            dateFomater.dateFormat = "HH:mm"
                            
                            self.sunriseTime = dateFomater.string(from: sunriseDate as Date)
                            self.sunsetTime = dateFomater.string(from: sunsetDate as Date)
                            
                            self.detailsInfo.removeAll()
                            
                            self.detailsInfo += ["SUNRISE: \(self.sunriseTime)", "SUNSET: \(self.sunsetTime)", "FEELS LIKE: \(self.tempFeelsLike)°C", "HUMIDITY: \(self.humidity)%", "PRESSURE: \(self.pressure)hPa"]
                            
                             DispatchQueue.main.async {
                           self.detailInfoTableView.reloadData()
                            }
                        }
                    }
                }
                dataTask.resume()
            }
        }
}

extension MainWeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height/5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let detailInfoCell = tableView.dequeueReusableCell(withIdentifier: String(describing: WeatherDetailsTableViewCell.self), for: indexPath) as? WeatherDetailsTableViewCell
            else {
                return UITableViewCell()
        }
        detailInfoCell.detailInfoLabel.text = detailsInfo[indexPath.row]
        
        return detailInfoCell
    }
}
