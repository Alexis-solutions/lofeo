//
//  AvatarCell.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 11/03/26.
//
import UIKit

class AvatarCell: UICollectionViewCell {

    
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var statusDot: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print("avatarButton.frame.height: \(avatarButton.frame.height)")

        avatarButton.layer.cornerRadius = avatarButton.frame.height / 2
        avatarButton.clipsToBounds = true

           
    
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarButton.layer.cornerRadius = avatarButton.frame.height / 2
        avatarButton.clipsToBounds = true
    }
    func addBrokenBorder() {
        
        let yellowLayer = CAShapeLayer()
        yellowLayer.name = "brokenBorder"
        yellowLayer.strokeColor = UIColor.systemYellow.cgColor
        yellowLayer.fillColor = UIColor.clear.cgColor
        yellowLayer.lineWidth = 5
        yellowLayer.lineDashPattern = [8,4]
        yellowLayer.frame = avatarButton.bounds
        
        yellowLayer.path = UIBezierPath(
            roundedRect: avatarButton.bounds,
            cornerRadius: avatarButton.frame.height / 2
        ).cgPath
        
        avatarButton.layer.addSublayer(yellowLayer)
        
        
        let whiteLayer = CAShapeLayer()
        whiteLayer.name = "brokenBorder" // Same tag
        whiteLayer.strokeColor = UIColor.white.cgColor
        whiteLayer.fillColor = UIColor.clear.cgColor
        whiteLayer.lineWidth = 5
        whiteLayer.lineDashPattern = [4,8]
        whiteLayer.frame = avatarButton.bounds
        
        whiteLayer.path = UIBezierPath(
            roundedRect: avatarButton.bounds,
            cornerRadius: avatarButton.frame.height / 2
        ).cgPath
        
        avatarButton.layer.addSublayer(whiteLayer)
    }
    
    func removeBrokenBorder() {
            avatarButton.layer.sublayers?.removeAll(where: { $0.name == "brokenBorder" })
        }
    
    
}
