//
//  BaseTableViewCell.swift
//  GetMe
//
//  Created by Vladyslav Vdovycheko on 28.10.2020.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        // Configure the view for the selected state
    }
    
    func setupCell(with object: Any) { //for override
        // do not call super.setupCell()!
        fatalError("Need to override")
    }
    
}
