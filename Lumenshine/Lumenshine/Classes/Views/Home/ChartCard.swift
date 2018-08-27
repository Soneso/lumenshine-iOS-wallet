//
//  ChartCard.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/12/18.
//  Copyright © 2018 Soneso. All rights reserved.
//


import UIKit
import Charts
import SnapKit
import Material

class ChartCard: CardView {
    
    fileprivate let lineChartView = LineChartView()
    fileprivate let titleLabel = UILabel()
    fileprivate let detailLabel = UILabel()
    fileprivate let periodPicker = UITextField()
    fileprivate let currentRateLabel = UILabel()
    fileprivate let percentageChangeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var viewModel: CardViewModelType? {
        didSet {
            if let viewModel = viewModel as? ChartCardViewModel {
                setTitle(viewModel.title)
                setPeriodPicker(viewModel.periodOptions, selectedIndex: viewModel.selectedPeriodIndex)
                setDetail(viewModel.detail)
                setChart(rates: viewModel.exchangeRates?.rates)
                setChartLabels(currentRate: viewModel.currentRate, percentageChange: viewModel.percentageChange)
                
                viewModel.reloadClosure = { [weak self] exchangeRates in
                    DispatchQueue.main.async {
                        self?.setDetail(viewModel.detail)
                        self?.setChart(rates: exchangeRates.rates)
                        self?.setChartLabels(currentRate: viewModel.currentRate, percentageChange: viewModel.percentageChange)
                    }
                }
            }
        }
    }
}

extension ChartCard {    
    func setTitle(_ text: String?) {
        titleLabel.text = text
    }
    
    func setDetail(_ detail: String?) {
        detailLabel.text = detail
    }
    
    func setPeriodPicker(_ options: [String], selectedIndex: Int) {
        let enumPicker = EnumPicker()
        enumPicker.setValues(options, currentSelection: selectedIndex) { [weak self] newIndex in
            self?.periodPicker.text = options[newIndex]
            (self?.viewModel as! ChartCardViewModel).periodSelected(at: newIndex)
            self?.setDetail(self?.viewModel?.detail)
        }
        periodPicker.inputView = enumPicker
        periodPicker.text = options[selectedIndex]
    }
    
    func setChart(rates: Array<ExchangeRateResponse>?) {
        guard let values = rates else { return }
        var dataEntries: [ChartDataEntry] = []
        
        for (index, item) in values.reversed().enumerated() {
            let value = NSDecimalNumber(decimal:item.rate).doubleValue
            let dataEntry = ChartDataEntry(x: Double(index), y: value)
            dataEntries.append(dataEntry)
        }
        
        let line1 = LineChartDataSet(values: dataEntries, label: nil)
        line1.colors = [Stylesheet.color(.white)]
        line1.mode = .cubicBezier
        line1.fill = Fill(color: Stylesheet.color(.white))
        line1.fillColor = Stylesheet.color(.white)
        line1.drawValuesEnabled = false
        line1.drawCirclesEnabled = false
        lineChartView.data = LineChartData(dataSets: [line1])
        
        lineChartView.gridBackgroundColor = Stylesheet.color(.clear)
        lineChartView.drawGridBackgroundEnabled = false
        
        lineChartView.isUserInteractionEnabled = false
        lineChartView.xAxisRenderer = XAxisRenderer(viewPortHandler: lineChartView.viewPortHandler, xAxis: nil, transformer: nil)
        lineChartView.leftYAxisRenderer.axis?.gridColor = Stylesheet.color(.white)
        lineChartView.leftYAxisRenderer.axis?.drawLabelsEnabled = false
        lineChartView.leftYAxisRenderer.axis?.drawAxisLineEnabled = false
        
        lineChartView.rightYAxisRenderer.axis?.gridColor = Stylesheet.color(.white)
        lineChartView.rightYAxisRenderer.axis?.drawLabelsEnabled = false
        lineChartView.rightYAxisRenderer.axis?.drawAxisLineEnabled = false
        lineChartView.chartDescription?.text = nil
    }
    
    func setChartLabels(currentRate: String?, percentageChange: String?) {
        currentRateLabel.text = currentRate
        percentageChangeLabel.text = percentageChange
    }
}

fileprivate extension ChartCard {
    func prepare() {
        contentView.backgroundColor = Stylesheet.color(.cyan)
        
        prepareTitle()
        prepareDetail()
        prepareChart()
        prepareRate()
        preparePercentage()
        preparePeriodPicker()
    }
    
    func prepareTitle() {
        titleLabel.textColor = Stylesheet.color(.white)
        titleLabel.font = Stylesheet.font(.body)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
    }
    
    func prepareDetail() {
        detailLabel.textColor = Stylesheet.color(.white)
        detailLabel.font = Stylesheet.font(.callout)
        detailLabel.textAlignment = .left
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.numberOfLines = 0
        
        contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
    }
    
    func prepareChart() {
        contentView.addSubview(lineChartView)
        lineChartView.snp.makeConstraints { (make) in
            make.top.equalTo(detailLabel.snp.top).offset(15)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(180)
        }
    }
    
    func prepareRate() {
        currentRateLabel.textColor = Stylesheet.color(.white)
        currentRateLabel.font = Stylesheet.font(.callout)
        currentRateLabel.textAlignment = .left
        currentRateLabel.adjustsFontSizeToFitWidth = true
        
        contentView.addSubview(currentRateLabel)
        currentRateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineChartView.snp.bottom).offset(5)
            make.left.equalTo(10)
            make.bottom.equalTo(bottomBar.snp.top).offset(-5)
        }
    }
    
    func preparePercentage() {
        percentageChangeLabel.textColor = Stylesheet.color(.white)
        percentageChangeLabel.font = Stylesheet.font(.callout)
        percentageChangeLabel.textAlignment = .right
        percentageChangeLabel.adjustsFontSizeToFitWidth = true
        
        contentView.addSubview(percentageChangeLabel)
        percentageChangeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineChartView.snp.bottom).offset(5)
            make.left.equalTo(currentRateLabel.snp.right)
            make.right.equalTo(-10)
            make.bottom.equalTo(bottomBar.snp.top).offset(-5)
        }
    }
    
    func preparePeriodPicker() {
        periodPicker.adjustsFontSizeToFitWidth = true
        periodPicker.borderStyle = .roundedRect
        periodPicker.rightViewMode = .always
        periodPicker.rightView = UIImageView(image: Icon.cm.arrowDownward)
        bottomBar.leftViews = [periodPicker]
    }
}


