//
//  ChartCard.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/12/18.
//  Copyright © 2018 Soneso. All rights reserved.
//


import UIKit
import Charts
import SnapKit

protocol ChartCardProtocol {
    func setTitle(_ text: String?)
    func setDetail(_ detail: String?)
}

class ChartCard: Card {
    
    fileprivate let lineChartView = LineChartView()
    fileprivate let titleLabel = UILabel()
    fileprivate let detailLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var viewModel: CardViewModelType? {
        didSet {
            setTitle(viewModel?.title)
            setDetail(viewModel?.detail)
        }
    }
}

extension ChartCard: ChartCardProtocol {    
    func setTitle(_ text: String?) {
        titleLabel.text = text
    }
    
    func setDetail(_ detail: String?) {
        detailLabel.text = detail
    }
}

fileprivate extension ChartCard {
    func prepare() {
        
        cornerRadiusPreset = .cornerRadius3
        depthPreset = .depth3
        
        backgroundColor = Stylesheet.color(.cyan)
        
        prepareChart()
        prepareTitle()
        prepareDetail()
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: values[i], y: Double(i))
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "EUR 0.244")
        lineChartDataSet.mode = .cubicBezier
        let lineChartData = LineChartData(dataSets: [lineChartDataSet])
//        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        
    }
    
    func prepareChart() {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        let unitsSold = [2.0, 4.0, 6.0, 3.0, 12.0, 16.0]
        
        setChart(dataPoints: months, values: unitsSold)
        
        addSubview(lineChartView)
        lineChartView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(200)
            make.bottom.equalTo(bottomBar.snp.top).offset(-5)
        }
    }
    
    func prepareTitle() {
        titleLabel.textColor = Stylesheet.color(.black)
        titleLabel.font = Stylesheet.font(.body)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
    }
    
    func prepareDetail() {
        detailLabel.textColor = Stylesheet.color(.black)
        detailLabel.font = Stylesheet.font(.callout)
        detailLabel.textAlignment = .left
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.numberOfLines = 0
        
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(lineChartView.snp.top).offset(-5)
        }
    }
}




