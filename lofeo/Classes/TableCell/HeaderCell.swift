//
//  HeaderCell.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 09/04/26.
//
import UIKit

class HeaderCell:  UICollectionViewCell{
    
    @IBOutlet weak var headerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

}


