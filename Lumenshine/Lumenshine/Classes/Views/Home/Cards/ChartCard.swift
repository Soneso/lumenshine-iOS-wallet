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
    
    // MARK: - UI properties
    fileprivate let lineChartView = LineChartView()
    fileprivate let titleLabel = UILabel()
    fileprivate let detailLabel = UILabel()
    fileprivate let periodPicker = UITextField()
    fileprivate let currentRateLabel = UILabel()
    fileprivate let percentageChangeLabel = UILabel()
    fileprivate let horizontalSpacing = 15.0    
    
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
        line1.colors = [Stylesheet.color(.blue)]
        line1.mode = .cubicBezier
        line1.form = .none
        line1.drawValuesEnabled = false
        line1.drawCirclesEnabled = false
        line1.drawFilledEnabled = true
        line1.lineWidth = 2.0
        lineChartView.data = LineChartData(dataSets: [line1])
        
        lineChartView.gridBackgroundColor = Stylesheet.color(.clear)
        lineChartView.drawGridBackgroundEnabled = false
        
        lineChartView.isUserInteractionEnabled = false
        lineChartView.xAxisRenderer.axis?.gridColor = Stylesheet.color(.lightGray)
        lineChartView.xAxisRenderer.axis?.drawLabelsEnabled = false
        lineChartView.xAxisRenderer.axis?.drawAxisLineEnabled = false
        
        lineChartView.leftYAxisRenderer.axis?.gridColor = Stylesheet.color(.lightGray)
        lineChartView.leftYAxisRenderer.axis?.drawLabelsEnabled = false
        lineChartView.leftYAxisRenderer.axis?.drawAxisLineEnabled = false
        
        lineChartView.rightYAxisRenderer.axis?.gridColor = Stylesheet.color(.lightGray)
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
        contentView.backgroundColor = Stylesheet.color(.white)
        
        prepareTitle()
        prepareDetail()
        prepareChart()
        prepareRate()
        preparePercentage()
        preparePeriodPicker()
    }
    
    func prepareTitle() {
        titleLabel.textColor = Stylesheet.color(.lightBlack)
        titleLabel.font = R.font.encodeSansSemiBold(size: 12)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareDetail() {
        detailLabel.textColor = Stylesheet.color(.lightBlack)
        detailLabel.font = R.font.encodeSansRegular(size: 12)
        detailLabel.textAlignment = .left
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.numberOfLines = 0
        
        contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareChart() {
        contentView.addSubview(lineChartView)
        lineChartView.snp.makeConstraints { (make) in
            make.top.equalTo(detailLabel.snp.top).offset(15)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.height.equalTo(170)
        }
    }
    
    func prepareRate() {
        currentRateLabel.textColor = Stylesheet.color(.lightBlack)
        currentRateLabel.font = R.font.encodeSansSemiBold(size: 12)
        currentRateLabel.textAlignment = .left
        currentRateLabel.adjustsFontSizeToFitWidth = true
        
        contentView.addSubview(currentRateLabel)
        currentRateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineChartView.snp.bottom)
            make.left.equalTo(horizontalSpacing)
            make.bottom.equalTo(bottomBar.snp.top).offset(-horizontalSpacing)
        }
    }
    
    func preparePercentage() {
        percentageChangeLabel.textColor = Stylesheet.color(.lightBlack)
        percentageChangeLabel.font = R.font.encodeSansSemiBold(size: 12)
        percentageChangeLabel.textAlignment = .right
        percentageChangeLabel.adjustsFontSizeToFitWidth = true
        
        contentView.addSubview(percentageChangeLabel)
        percentageChangeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineChartView.snp.bottom)
            make.left.equalTo(currentRateLabel.snp.right)
            make.right.equalTo(-horizontalSpacing)
            make.bottom.equalTo(bottomBar.snp.top).offset(-horizontalSpacing)
        }
    }
    
    func preparePeriodPicker() {
        periodPicker.textColor = Stylesheet.color(.blue)
        periodPicker.font = R.font.encodeSansSemiBold(size: 12)
        periodPicker.adjustsFontSizeToFitWidth = true
        periodPicker.borderStyle = .roundedRect
        periodPicker.rightViewMode = .always
        periodPicker.rightView = UIImageView(image: Icon.cm.arrowDownward?.tint(with: Stylesheet.color(.gray)))
        bottomBar.leftViews = [periodPicker]
    }
}


