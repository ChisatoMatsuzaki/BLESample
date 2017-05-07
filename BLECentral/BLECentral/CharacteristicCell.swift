//
//  CharacteristicCell.swift
//  BLECentral
//
//  Created by Chisato Matsuzaki on 2017/05/04.
//  Copyright © 2017年 Chisato Matsuzaki. All rights reserved.
//

import UIKit

class CharacteristicCell: UITableViewCell {

    @IBOutlet weak var uuidLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
