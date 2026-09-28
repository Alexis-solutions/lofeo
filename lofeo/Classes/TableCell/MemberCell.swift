//
//  MemberCell.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 14/03/26.
//

import UIKit

class MemberCell: UICollectionViewCell  {

 
    @IBOutlet weak var AvatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var call: UIButton!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

}
