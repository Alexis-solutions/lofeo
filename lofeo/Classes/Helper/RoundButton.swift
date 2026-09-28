//
//  RoundButton.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 25/03/26.
//

import UIKit


class RoundButton : UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.frame.size.width != self.frame.size.height {
            let minSize = min(self.frame.size.width, self.frame.size.height)
            self.frame.size = CGSize(width: minSize, height: minSize)
        }
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
        
    }
}
