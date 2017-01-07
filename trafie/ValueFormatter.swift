//
//  ValueFormatter.swift
//  trafie
//
//  Created by mathiou on 03/01/2017.
//  Copyright © 2017 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import UIKit
import Charts

public class YValueFormatter: NSObject, IValueFormatter {
  
  fileprivate var discipline: String = ""
  
  public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
    let res: String = Utils.convertPerformanceToReadable(String(value), discipline: self.discipline, measurementUnit: MeasurementUnits.Meters.rawValue )
    return res
  }


  public func setDiscipline(discipline: String) {
    self.discipline = discipline
  }
}

