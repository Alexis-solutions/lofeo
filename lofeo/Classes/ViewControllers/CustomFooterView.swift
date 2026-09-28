//
//  CustomFooterView.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 10/03/26.
//

import UIKit


protocol CustomFooterViewDelegate: AnyObject {
    func didTapHome()
    func didTapCircle()
    func didTapServices()
    func didTapSettings()
    func didTapSOS()
}

class CustomFooterView: UIView {
    
    weak var delegate: CustomFooterViewDelegate?

    let homeButton = UIButton()
    let circleButton = UIButton()
    let sosButton = UIButton()
    let servicesButton = UIButton()
    let settingsButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFooter()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFooter()
    }

    private func setupFooter() {

        backgroundColor = .white

        let spacer = UIView()

        let stack = UIStackView(arrangedSubviews: [
            homeButton,
            circleButton,
            spacer,
            servicesButton,
            settingsButton
        ])

        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.heightAnchor.constraint(equalToConstant: 60)
        ])

        setupButtons()
        setupSOSButton()
    }



    private func setupButtons() {

        configureButton(homeButton, title: "Home", icon: "house")
        configureButton(circleButton, title: "Circle", icon: "person.2")
        configureButton(servicesButton, title: "Services", icon: "globe")
        configureButton(settingsButton, title: "Settings", icon: "gear")
        
        homeButton.addTarget(self, action: #selector(homeTapped), for: .touchUpInside)
        circleButton.addTarget(self, action: #selector(circleTapped), for: .touchUpInside)
        servicesButton.addTarget(self, action: #selector(servicesTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        sosButton.addTarget(self, action: #selector(sosTapped), for: .touchUpInside)
    }

    
    func configureButton(_ button: UIButton, title: String, icon: String) {

        var config = UIButton.Configuration.plain()
        
        config.title = title
        config.image = UIImage(systemName: icon)
        
        config.imagePlacement = .top
        config.imagePadding = 6

        config.baseForegroundColor = .black

        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var updated = incoming
            updated.font = UIFont.boldSystemFont(ofSize: 12)
            updated.foregroundColor = .black
            return updated
        }

        button.configuration = config
    }
    

    private func setupSOSButton() {

        sosButton.setTitle("SOS", for: .normal)
        sosButton.setTitleColor(.white, for: .normal)
        sosButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)

        sosButton.layer.cornerRadius = 36
        sosButton.layer.masksToBounds = false

        // Border like CSS
        sosButton.layer.borderWidth = 6
        sosButton.layer.borderColor = UIColor.systemBackground.cgColor

        // Shadow like CSS
        sosButton.layer.shadowColor = UIColor(red: 224/255, green: 122/255, blue: 95/255, alpha: 1).cgColor
        sosButton.layer.shadowOpacity = 0.4
        sosButton.layer.shadowOffset = CGSize(width: 0, height: 12)
        sosButton.layer.shadowRadius = 12

        sosButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sosButton)

        NSLayoutConstraint.activate([
            sosButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            sosButton.topAnchor.constraint(equalTo: topAnchor, constant: -30),
            sosButton.widthAnchor.constraint(equalToConstant: 72),
            sosButton.heightAnchor.constraint(equalToConstant: 72)
           
        ])

        addGradient()
    }
    func addGradient() {

        let gradient = CAGradientLayer()

        gradient.colors = [
            UIColor(red: 224/255, green: 122/255, blue: 95/255, alpha: 1).cgColor,
            UIColor(red: 214/255, green: 106/255, blue: 79/255, alpha: 1).cgColor
        ]

        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)

        gradient.frame = CGRect(x: 0, y: 0, width: 72, height: 72)
        gradient.cornerRadius = 36

        sosButton.layer.insertSublayer(gradient, at: 0)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.15) {
            self.sosButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.15) {
            self.sosButton.transform = .identity
        }
    }
    
    @objc func homeTapped() {
        delegate?.didTapHome()
    }

    @objc func circleTapped() {
       delegate?.didTapCircle()
    }

    @objc func servicesTapped() {
        delegate?.didTapServices()
    }

    @objc func settingsTapped() {
        delegate?.didTapSettings()
    }

    @objc func sosTapped() {
        delegate?.didTapSOS()
    }
    
}


