//
//  ChartsVC.swift
//  trafie
//
//  Created by mathiou on 31/10/2016.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class ChartsVC: UIViewController, UIScrollViewDelegate, ChartViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var barView: BarChartView!
  @IBOutlet weak var disciplinesCollectionView: UICollectionView!
  @IBOutlet weak var yearsCollectionView: UICollectionView!
  @IBOutlet weak var chartTitle: UILabel!
  
  let yAxisFormatter = YAxisValueFormater()
  let xAxisFormatter = XAxisValueFormater()
  let yValueFormatter = YValueFormatter()
  var selectedDiscipline: String = "decathlon"
  var selectedYear: String = ""
  var _activities = uiRealm.objects(ActivityModelObject.self)
  let localUserMainDiscipline: String = UserDefaults.standard.object(forKey: "mainDiscipline") as! String

  // TODO: find more proper names
  var _userDisciplines = Array<String>()
  var _userYears = Array<String>()
  // ------------------------------
  var ll = ChartLimitLine(limit: 0.0, label: "")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let localUserMainDiscipline: String = UserDefaults.standard.object(forKey: "mainDiscipline") as! String
    self.selectedDiscipline = localUserMainDiscipline
    self.setChartTitle(discipline: self.selectedDiscipline)
    self.setAvailableFilters()

    self._activities = self._activities.filter("discipline = '\(self.selectedDiscipline)'")
    self.disciplinesCollectionView.delegate = self
    self.disciplinesCollectionView.dataSource = self
    self.yearsCollectionView.delegate = self
    self.yearsCollectionView.dataSource = self
    barView.delegate = self
    generateData()
    barView.noDataText = "You need to provide data for the chart."
    barView.chartDescription?.text = ""
    barView.barData?.highlightEnabled = false
    barView.rightAxis.enabled = false
    barView.leftAxis.valueFormatter = self.yAxisFormatter
    barView.leftAxis.addLimitLine(ll)
    barView.leftAxis.drawLimitLinesBehindDataEnabled = false
    barView.xAxis.valueFormatter = xAxisFormatter
    barView.xAxis.gridColor = UIColor.white
    barView.xAxis.labelPosition = .bottom
    barView.xAxis.granularityEnabled = true
    barView.xAxis.granularity = 2.0
    barView.animate(xAxisDuration: 1.0, yAxisDuration: 1.5, easingOption: .linear)

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.setAvailableFilters()
    self._activities = uiRealm.objects(ActivityModelObject.self).filter("discipline = '\(self.selectedDiscipline)'")
    self.generateData()
  }

  // Data Generation
  private func generateData() {
    var dataEntries: [BarChartDataEntry] = []
    var sum: Double = 0

    var _xLabels: [String] = []
    dateFormatter.dateFormat = "MMM d"
    
    if self._activities.count > 0 {
      for i in 0 ... (self._activities.count - 1) {
        let _performance: Double = Double(self._activities[i].performance!)!
        let _date: String = dateFormatter.string(from: self._activities[i].date)
        sum = sum + _performance

        let dataEntry = BarChartDataEntry(x: Double(i) , y: _performance)
        _xLabels.append(_date)
        dataEntries.append(dataEntry)
      }
      self.yAxisFormatter.setDiscipline(discipline: self.selectedDiscipline)
      self.yValueFormatter.setDiscipline(discipline: self.selectedDiscipline)
      self.xAxisFormatter.setDateLabels(labelsList: _xLabels)
    }

    barView.leftAxis.removeAllLimitLines()
    let avg = sum / Double(self._activities.count)
    let avgLabel: String = Utils.convertPerformanceToReadable(String(describing: avg), discipline: self.selectedDiscipline , measurementUnit: MeasurementUnits.Meters.rawValue )
    ll = ChartLimitLine(limit: avg, label: "Avg: \(avgLabel)") //avg.roundTo(places: 2)
    barView.leftAxis.addLimitLine(ll)

    let chartDataSet = BarChartDataSet(values: dataEntries, label: "\(self.selectedDiscipline)")
    let chartData = BarChartData(dataSet: chartDataSet)
    chartDataSet.valueFormatter = self.yValueFormatter;
    chartDataSet.drawValuesEnabled = true
    
    self.barView.data = chartData
  }
  
  // Sets the available filters
  // changes years according the selected discipline
  private func setAvailableFilters() {
    self._userDisciplines = Array(Set(uiRealm.objects(ActivityModelObject.self).value(forKey: "discipline") as! [String]))
    self._userDisciplines = Utils.moveArrayElementToPosition(array: self._userDisciplines, element: self.localUserMainDiscipline, position: 0);
    let tmpActivities = uiRealm.objects(ActivityModelObject.self).filter("discipline = '\(self.selectedDiscipline)'")
    self._userYears = Array(Set(tmpActivities.value(forKey: "year") as! [String]))
    self._userYears.sort()
    self._userYears.insert("All", at: 0)

    self.yearsCollectionView.reloadData()
    self.disciplinesCollectionView.reloadData()
  }
  
  private func setChartTitle(discipline: String, year: String?="") {
    self.chartTitle.text = "\(NSLocalizedString(discipline, comment:"translation of discipline"))"
    if year != "" {
      self.chartTitle.text = self.chartTitle.text! + " \(Utils.fixOptionalString(year!))"
    } else {
      self.chartTitle.text = self.chartTitle.text! + " All Time"
    }
  }

  @objc func selectDiscipline(button: UIButton) {
    self.selectedDiscipline = _userDisciplines[button.tag]
    self._activities = uiRealm.objects(ActivityModelObject.self).filter("discipline = '\(self.selectedDiscipline)'")
    self.setChartTitle(discipline: self.selectedDiscipline)
    self.setAvailableFilters()
    self.generateData()
  }
  
  @objc func selectYear(button: UIButton) {
    switch(button.tag) {
    case 0:
      self._activities = uiRealm.objects(ActivityModelObject.self).filter("discipline = '\(self.selectedDiscipline)'")
      self.setChartTitle(discipline: self.selectedDiscipline)
      self.selectedYear = ""
      break
    default:
      self._activities = uiRealm.objects(ActivityModelObject.self).filter("discipline = '\(self.selectedDiscipline)' and year='\(_userYears[button.tag])'")
      self.setChartTitle(discipline: self.selectedDiscipline, year: _userYears[button.tag])
      self.selectedYear = Utils.fixOptionalString(_userYears[button.tag])
    }
    self.yearsCollectionView.reloadData()
    self.generateData()
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch collectionView.tag {
    case 0:
      return _userDisciplines.count
    case 1:
      return _userYears.count
    default:
      return 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // Disciplines
    if collectionView.tag == 0 {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "disciplinesSelectorCell", for: indexPath) as! DisciplinesCollectionViewCell
      cell.button.tag = indexPath[1]
      let _disciplineTitle: String = NSLocalizedString(_userDisciplines[cell.button.tag], comment:"translation of discipline")
      cell.button.setTitle(_disciplineTitle, for: .normal)
      cell.button.addTarget(self, action: #selector(self.selectDiscipline(button:)), for: .touchUpInside)
      cell.button.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10)
      // TODO: clean this mess
      if _userDisciplines[cell.button.tag] == self.selectedDiscipline {
        cell.button.backgroundColor = CLR_TRAFIE_RED
        cell.button.setTitleColor(UIColor.white, for: .normal)
      } else {
        cell.button.backgroundColor = UIColor.white
        cell.button.setTitleColor(CLR_DARK_GRAY, for: .normal)
      }
      return cell
    // Years
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "yearsSelectorCell", for: indexPath) as! YearsCollectionViewCell
      cell.button.tag = indexPath[1]
      let _yearTitle: String = Utils.fixOptionalString(_userYears[cell.button.tag])
      cell.button.setTitle(_yearTitle, for: .normal)
      cell.button.addTarget(self, action: #selector(self.selectYear(button:)), for: .touchUpInside)
      cell.button.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10)
      // TODO: clean this mess
      if _yearTitle == self.selectedYear || (_yearTitle == "All" && self.selectedYear == "") {
        cell.button.backgroundColor = CLR_TRAFIE_RED
        cell.button.setTitleColor(UIColor.white, for: .normal)
      } else {
        cell.button.backgroundColor = UIColor.white
        cell.button.setTitleColor(CLR_DARK_GRAY, for: .normal)
      }
      return cell
    }
  }
  
  //Use for size
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
    var title: String = ""
    if collectionView.tag == 0 {
      title = NSLocalizedString(_userDisciplines[indexPath[1]], comment:"translation of discipline")
    } else {
      title = Utils.fixOptionalString(_userYears[indexPath[1]])
    }
    
    // ugly hack to calculate the width for each cell
    let _width: Int = (title.characters.count * 8) + 10
    return CGSize(width: _width, height: 50)
  }

}

// TODO: move to a more proper place
extension Double {
  /// Rounds the double to decimal places value
  func roundTo(places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}
