//
//  BaseViewController.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 10/03/26.
//

import UIKit

class BaseViewController: UIViewController , CustomFooterViewDelegate {

    let footer = CustomFooterView()
    var loader: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFooter()
        footer.delegate = self
    }

    private func setupFooter() {

        footer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footer)

        NSLayoutConstraint.activate([
            footer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footer.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    func didTapHome() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        navigationController?.pushViewController(vc, animated: true)
       }

       func didTapCircle() {
           let vc = storyboard?.instantiateViewController(withIdentifier: "CircleViewController") as! CircleViewController
           navigationController?.pushViewController(vc, animated: true)
       }

       func didTapServices() {
           let vc = storyboard?.instantiateViewController(withIdentifier: "ServicesViewController") as! ServicesViewController
           navigationController?.pushViewController(vc, animated: true)
       }

       func didTapSettings() {
           let vc = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
           navigationController?.pushViewController(vc, animated: true)
       }

       func didTapSOS() {
        
           let vc = storyboard?.instantiateViewController(withIdentifier: "SoSViewController") as! SoSViewController
           navigationController?.pushViewController(vc, animated: true)
       }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
       present(alert, animated: true)
    }
    
    func showLoader() {
        loader = UIActivityIndicatorView(style: .large)
        loader?.center = self.view.center
        loader?.startAnimating()
        loader?.hidesWhenStopped = true
        
        view.addSubview(loader!)
        view.isUserInteractionEnabled = false // prevent clicks
    }

    func hideLoader() {
        loader?.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
}
