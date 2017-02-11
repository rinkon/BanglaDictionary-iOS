//
//  FavoriteTableViewCell.swift
//  BanglaDictionary
//
//  Created by Ashik Aowal on 2/10/17.
//  Copyright © 2017 MacMan. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if(isHighlighted){
            self.backgroundView?.backgroundColor = UIColor.black
        }
        // Configure the view for the selected state
    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        for subView in self.subviews{
//            for childView in subView.subviews{
//                if(childView is UIButton){
//                    childView.backgroundColor = UIColor.black
//                }
//            }
//        }
//    }

}
