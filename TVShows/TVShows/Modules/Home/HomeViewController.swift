//
//  HomeViewController.swift
//  TVShows
//
//  Created by Infinum on 15/07/2019.
//  Copyright © 2019 Infinum. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire
import PromiseKit
import SVProgressHUD
import Kingfisher
import KeychainAccess

final class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    private var tvShows = [TVShow]()
    private var loginCredentials: LoginData?
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupTableView()
        _displayTVShows()
        
        let logoutItem = UIBarButtonItem.init(image: UIImage(named: "ic-logout"),
            style: .plain,
            target: self,
            action: #selector(logoutActionHandler))
        navigationItem.leftBarButtonItem = logoutItem
    }
    
    // MARK: - Public methods
    func configureBeforeNavigating(with credentials: LoginData) {
        loginCredentials = credentials
    }
    
    // MARK: - Private methods
    @objc private func logoutActionHandler() {
        _deleteUserFromPersistance()
        
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        navigationController?.setViewControllers([loginViewController], animated: true)
    }
    
    private func _deleteUserFromPersistance() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsConstants.Keys.rememberMePressed.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsConstants.Keys.rememberedUser.rawValue)

//        let keychain = Keychain(service: KeychainConstants.keychainName.rawValue)
//        keychain[KeychainConstants.Keys.rememberMePressed.rawValue] = nil
//        keychain[KeychainConstants.Keys.rememberedUser.rawValue] = nil
    }
    
    private func _setupTableView() {
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    // Side effect: assigns the data fetched via API call to the property
    // tvShows, effectively causing the tableView to be reloaded
    private func _displayTVShows() {
        SVProgressHUD.show()
        
        firstly { () -> Promise<[TVShow]> in
            let headers = ["Authorization": loginCredentials!.token]
            return Alamofire
                .request(
                    "https://api.infinum.academy/api/shows",
                    method: .get,
                    encoding: JSONEncoding.default,
                    headers: headers
                ).validate()
                .responseDecodable([TVShow].self, keyPath: "data")
            }.done() { [weak self]  in
                print("Success: \($0)")
                self?.tvShows = $0
                self?.tableView.reloadData()
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch {
                print("API failure: \($0)")
        }
    }
}

// MARK: - UITableView
extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let showDetailsStoryboard = UIStoryboard(name: "ShowDetails", bundle: nil)
        let showDetailsViewController = showDetailsStoryboard.instantiateViewController(withIdentifier: "ShowDetailsViewController") as! ShowDetailsViewController
        showDetailsViewController.configureBeforeNavigating(with: tvShows[indexPath.row], credentials: loginCredentials!)
        
        navigationController?.pushViewController(showDetailsViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.tvShows.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
     
        return [delete]
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tvShows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TVShowTableViewCell.self), for: indexPath) as! TVShowTableViewCell
        
        cell.configure(with: tvShows[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
