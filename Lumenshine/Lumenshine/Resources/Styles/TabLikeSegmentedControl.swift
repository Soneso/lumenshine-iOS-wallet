//
//  TabLikeSegmentedControl.swift
//  Lumenshine
//
//  Created by Soneso on 09/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class TabLikeSegmentedControl: UISegmentedControl {
    private typealias gradientType = CAGradientLayer
    private var initialSetupComplete = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        subscribeToValueChanged()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !initialSetupComplete {
            updateSegments()
            initialSetupComplete = true
        }
    }
    
    private func setup() {
        setupView()
        setupTitle()
       
        snp.makeConstraints { (make) in
            make.height.equalTo(35)
        }
    }
    
    private func subscribeToValueChanged() {
        addTarget(self, action: #selector(segmentedControlValueChanged), for:.valueChanged)
    }
    
    private func setupTitle() {
        setTitleTextAttributes([
            NSAttributedString.Key.font : R.font.encodeSansSemiBold(size: 14)!,
            NSAttributedString.Key.foregroundColor: Stylesheet.color(.darkGray)
            ], for: .normal)
        
        setTitleTextAttributes([
            NSAttributedString.Key.font : R.font.encodeSansSemiBold(size: 14)!,
            NSAttributedString.Key.foregroundColor: Stylesheet.color(.lightBlack)
            ], for: .selected)
    }
    
    private func setupView() {
        tintColor = Stylesheet.color(.clear)
        backgroundColor = Stylesheet.color(.lightGray)
        borderWidthPreset = .none
    }
    
    private func setGradientBackground(toView view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Stylesheet.color(.white).cgColor, Stylesheet.color(.veryLightGray).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width + 1, height: view.bounds.height)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func removeGradientBackground(fromView view: UIView) {
        view.layer.sublayers?.first(where: { (layer) -> Bool in
            return layer is gradientType
        })?.removeFromSuperlayer()
    }
    
    private func getSortedViews() -> [UIView] {
        return subviews.sorted(by: { (first, second) -> Bool in
            return first.frame.minX < second.frame.minX
        })
    }
    
    private func updateSegments() {
        for (index, view) in getSortedViews().enumerated() {
            if index == selectedSegmentIndex {
                setGradientBackground(toView: view)
            } else {
                removeGradientBackground(fromView: view)
            }
        }
    }
    
    @objc func segmentedControlValueChanged() {
        updateSegments()
    }
}
