//
//  LogCell.swift
//  BLEPeripheral
//
//  Created by Chisato Matsuzaki on 2017/05/02.
//  Copyright © 2017年 Chisato Matsuzaki. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {

    // MARK: * Outlets *
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
