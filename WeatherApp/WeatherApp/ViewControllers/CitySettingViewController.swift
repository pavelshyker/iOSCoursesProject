//
//  CitySettingViewController.swift
//  WeatherApp
//
//  Created by Pavel Shyker on 2/2/21.
//  Copyright © 2021 Pavel Shyker. All rights reserved.
//

import UIKit

class CitySettingViewController: UIViewController {

    lazy var city: String = ""
    var citiesArray = [String]()
    @IBOutlet weak var citySettingsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        // Do any additional setup after loading the view.
        citySettingsTableView.dataSource = self
        citySettingsTableView.delegate = self
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.becomeFirstResponder()
        searchBar.enablesReturnKeyAutomatically = true
        citiesArray = UserDefaults.standard.value(forKey: "citiesArray") as? [String] ?? [String]()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        citySettingsTableView.isHidden = true
        
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Oops!", message: "Sorry, city is not found", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Close", style: .cancel)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    func navigateToCitiesList() {
        let citiesListStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let citiesListViewController = citiesListStoryBoard.instantiateViewController(withIdentifier: String(describing: CitiesListViewController.self)) as? CitiesListViewController
        navigationController?.pushViewController(citiesListViewController ?? UIViewController(), animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension CitySettingViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigateToCitiesList()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        city = searchBar.text ?? "textFromSearch"
        let modifiedCityName = city.replacingOccurrences(of: " ", with: "%20")
        let urlString = "http://api.openweathermap.org/data/2.5/weather?q=\(modifiedCityName)&appid=d43387d585d6c819d788f05ee55d9b5c"
        if let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                guard error == nil else {
                    print(error?.localizedDescription ?? "Somethong wrong")
                    return
                }
                if let data = data {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    let responseDict = json as? [String: Any]
                        if let code = responseDict?["cod"] as? String {
                            DispatchQueue.main.async {
                            self.showAlert()
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.citySettingsTableView.isHidden = false
                                self.citySettingsTableView.reloadData()
                            }
                        }
                    }
                }
            }
            dataTask.resume()
        }
    }
}

extension CitySettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let citySettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: String (describing: CitySettingsTableViewCell.self)) as? CitySettingsTableViewCell
            else {
                return UITableViewCell()
        }
        citySettingsTableViewCell.cityToAddLabel.text = searchBar.text?.uppercased()
        return citySettingsTableViewCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedRowCell = tableView.cellForRow(at: indexPath)
        city = selectedRowCell?.detailTextLabel?.text ?? self.city
        if !citiesArray.contains(city.uppercased()) {
        self.citiesArray.append(self.city.uppercased())
        UserDefaults.standard.setValue(self.citiesArray, forKey: "citiesArray")
        }
        navigateToCitiesList()
    }
}
