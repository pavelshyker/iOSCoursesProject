//
//  GuardViewController.swift
//  Homework23_PicturesRepository
//
//  Created by Pavel Shyker on 11/26/20.
//  Copyright © 2020 Pavel Shyker. All rights reserved.
//

import UIKit
import SwiftyKeychainKit

class GuardViewController: UIViewController {
    
    private let imagePickerController = UIImagePickerController()
    var imagesArray = [UIImage]()
    var isImagesPathFull = false
    
    let keychain = Keychain(service: "test.Homework23-PicturesRepository")
    let currentUserNameKey = KeychainKey<String>(key: "currentUserNameKey")
    let credentialsKey = KeychainKey<Data>(key: "credentialsKey")
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileManager = FileManager.default
    lazy var imagesPath = documentsPath.appendingPathComponent("Images")
    
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePickerController.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let backButton = UIBarButtonItem()
        backButton.title = "Photos"
        navigationItem.backBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if isImagesPathFull == false {
        if let userName = try? keychain.get(currentUserNameKey) {
            imagesPath = imagesPath.appendingPathComponent("\(userName)")
            updateImagesArray()
            isImagesPathFull = true
            }
        }
        
        if fileManager.fileExists(atPath: imagesPath.path) == false {
            do { try fileManager.createDirectory(atPath: imagesPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print (error.localizedDescription)
            }
        }
        if imagesArray.isEmpty {
            collectionView.isHidden = true
        }
        else {
            collectionView.isHidden = false
        }
    }
    
    func updateImagesArray() {
        do {
            imagesArray = [UIImage]()
            let imageNames = try fileManager.contentsOfDirectory(atPath: imagesPath.path)
            if imageNames.count > 0 {
            for i in 0...imageNames.count - 1 {
                let imageName = imageNames[i]
                let imagePath = imagesPath.appendingPathComponent(imageName).path
                if let imageFromDir = fileManager.contents(atPath: imagePath) {
                    if let convertedImage = UIImage(data: imageFromDir) {
                            imagesArray.append(convertedImage)
                    }
                }
                }
            }
        }
        catch {
            print (error.localizedDescription)
        }
    }
    
    func saveImage(_ image: UIImage) {
        let data = image.pngData()
        let imagePath = imagesPath.appendingPathComponent("\(Date().timeIntervalSince1970).png")
        fileManager.createFile(atPath: imagePath.path, contents: data, attributes: nil)
    }
    
    @IBAction func addImageButtonTapped(_ sender: Any) {
        present(imagePickerController, animated: true)
    }
}

extension GuardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
        saveImage(image)
        imagesArray.append(image)
        }
        imagePickerController.dismiss(animated: true)
        collectionView.reloadData()
    }
}

extension GuardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imagesArray.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCollectionViewCell.self), for: indexPath) as? ImageCollectionViewCell else {
       return UICollectionViewCell()
    }
    let cellImage = imagesArray[indexPath.item]
    cell.imageView.image = cellImage
    return cell
    }
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3 - 1, height: collectionView.frame.width/3 - 1)
    }
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    do {
    let folderImagesNames = try fileManager.contentsOfDirectory(atPath: imagesPath.path)
    let tappedImageName = folderImagesNames[indexPath.item]
    let tappedImagePath = imagesPath.appendingPathComponent(tappedImageName).path
        UserDefaults.standard.setValue(tappedImagePath, forKey: .imagesPathFull)
    }
    catch {
        print(error.localizedDescription)
    }
    
    let previewStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    let previewViewController = previewStoryBoard.instantiateViewController(withIdentifier: String(describing: ImagePreviewViewController.self)) as? ImagePreviewViewController
    navigationController?.pushViewController(previewViewController ?? UIViewController(), animated: true)
    }
}
