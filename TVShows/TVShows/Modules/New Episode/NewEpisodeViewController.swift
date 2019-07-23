//
//  NewEpisodeViewController.swift
//  TVShows
//
//  Created by Infinum on 23/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire
import PromiseKit
import SVProgressHUD

protocol NewEpisodeReloadTableViewDelegate: class {
    func newEpisodeAdded()
}

class NewEpisodeViewController: UIViewController {
    
    @IBOutlet weak var episodeTitleTextField: UITextField!
    @IBOutlet weak var seasonNumberTextField: UITextField!
    @IBOutlet weak var episodeNumberTextField: UITextField!
    @IBOutlet weak var episodeDescriptionTextField: UITextField!
    @IBOutlet weak var episodeImage: UIImageView!
    
    weak var newEpisodeDelegate: NewEpisodeReloadTableViewDelegate?
    var loginCredentials: LoginData?
    var show: TVShow?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = "Add episode"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(didSelectCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(didSelectAddShow)
        )
        
        let pink = UIColor(rgb: 0xFF758C)
        navigationItem.leftBarButtonItem?.tintColor = pink
        navigationItem.rightBarButtonItem?.tintColor = pink
    }
    
    @objc func didSelectAddShow() {
        _registerNewEpisode()
    }
    
    @objc func didSelectCancel() {
        _navigateToShowDetailsViewController()
    }
    
    
    private func _navigateToShowDetailsViewController() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func _registerNewEpisode() {
        let headers = ["Authorization": loginCredentials!.token]
        Alamofire
            .request(
                "https://api.infinum.academy/api/episodes",
                method: .post,
                parameters: [
                    "showId": "s",
                    "mediaId": "s",
                    "title": "string",
                    "description": "string",
                    "episodeNumber": "string",
                    "season": "string"
                ],
                encoding: JSONEncoding.default,
                headers: headers
            ).validate()
    }
    
    private func _displayFailedEpisodeRegistrationAlert() {
        let alertController = UIAlertController(title: "Could not add new episode", message: "Please check the validity of provided data for registering new episode.", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Ok", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
}
