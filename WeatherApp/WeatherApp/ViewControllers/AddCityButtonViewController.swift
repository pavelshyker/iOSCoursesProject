//
//  AddCityButtonViewController.swift
//  WeatherApp
//
//  Created by Pavel Shyker on 2/4/21.
//  Copyright © 2021 Pavel Shyker. All rights reserved.
//

import UIKit

class AddCityButtonViewController: UIViewController {

    @IBOutlet var infoLabel: UIView!
    @IBOutlet weak var addCityButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func addCityButtonTapped(_ sender: Any) {
        let citiesListStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let citiesListViewController = citiesListStoryBoard.instantiateViewController(withIdentifier: String(describing: CitiesListViewController.self)) as? CitiesListViewController
        navigationController?.pushViewController(citiesListViewController ?? UIViewController(), animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
