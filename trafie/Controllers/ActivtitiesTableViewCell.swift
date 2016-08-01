//
//  ActivtitiesTableViewCell.swift
//  trafie
//
//  Created by mathiou on 6/28/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit

class ActivtitiesTableViewCell: UITableViewCell {
  
  @IBOutlet weak var performanceLabel: UILabel!
  @IBOutlet weak var competitionLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var notSyncedLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}
