//
//  ImagePreviewViewController.swift
//  Homework23_PicturesRepository
//
//  Created by Pavel Shyker on 1/3/21.
//  Copyright © 2021 Pavel Shyker. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    let fileManager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if let imagePath = UserDefaults.standard.value(forKey: .imagesPathFull) {
            if let imageFromDir = fileManager.contents(atPath: imagePath as? String ?? "") {
                if let convertedImage = UIImage(data: imageFromDir) {
                    imageView.image = convertedImage
                }
            }
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let deleteAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete photo", style: .destructive) { (_) in
            do {
                let imagePath = UserDefaults.standard.value(forKey: .imagesPathFull) as? String ?? ""
                if let imageFromDir = self.fileManager.contents(atPath: imagePath as? String ?? "") {
                    try self.fileManager.removeItem(atPath: imagePath)
                }
            }
            catch {
                print(error.localizedDescription)
            }
            
            let guardStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let guardViewController = guardStoryBoard.instantiateViewController(withIdentifier: String(describing: GuardViewController.self)) as? GuardViewController
            self.navigationController?.pushViewController(guardViewController ?? UIViewController(), animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        deleteAlert.addAction(deleteAction)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true)
    }
}
