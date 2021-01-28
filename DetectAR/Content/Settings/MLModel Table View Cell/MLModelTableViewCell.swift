//
//  MLModelTableViewCell.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 25.01.2021.
//

import UIKit

class MLModelTableViewCell: BaseTableViewCell {

    @IBOutlet weak var modelDescriptionLabel: UILabel!
    @IBOutlet weak var modelNameLabel: UILabel!
    @IBOutlet weak var checkmark: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkmark.isHidden = !selected
    }
    
    override func setupCell(with object: Any) {
        if let model = object as? Model {
            self.modelDescriptionLabel.text = model.information
            self.modelNameLabel.text = model.title
        }
    }
    
}
