//
//  AxisValueFormater.swift
//  trafie
//
//  Created by mathiou on 17/11/2016.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import Foundation
import Charts

@objc(BarChartFormatter)
public class YAxisValueFormater: NSObject, IAxisValueFormatter{

  fileprivate var discipline: String = ""

  // Override stringForValue for IAxisValueFormatter
  public func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String
  {
    let res: String = Utils.convertPerformanceToReadable(String(value), discipline: self.discipline, measurementUnit: MeasurementUnits.Meters.rawValue )

    return res
  }
  
  public func setDiscipline(discipline: String) {
    self.discipline = discipline
  }
}


@objc(BarChartFormatter)
public class XAxisValueFormater: NSObject, IAxisValueFormatter{

  fileprivate var dateLabels: [String] = []
  
  // Override stringForValue for IAxisValueFormatter
  public func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String
  {
    // secure index for label in x.
    let idx = Int(value) > self.dateLabels.count ? (self.dateLabels.count - 1 ): Int(value)
    let res: String = self.dateLabels[idx]
    return res
  }

  public func setDateLabels(labelsList: [String]) {
    self.dateLabels = labelsList
  }

}






