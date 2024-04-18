//
//  ListTableViewCell.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/18.
//

import UIKit

class ListTableViewCell: UITableViewCell {
 
    @IBOutlet weak var area: UILabel!
    @IBOutlet weak var weatherImage: UIImage!
    @IBOutlet weak var minTemperature: UILabel!
    @IBOutlet weak var maxTemperature: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
