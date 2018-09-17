//
//  LSButton.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 9/17/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LSButton: RaisedButton {
    
    init() {
        super.init(frame: .zero)
        titleColor = Stylesheet.color(.white)
        titleLabel?.adjustsFontSizeToFitWidth = true
        cornerRadiusPreset = .cornerRadius6
        titleLabel?.font = R.font.encodeSansSemiBold(size: 15)
        clipsToBounds = true
    }
    
    func setGradientLayer(color: UIColor) {
        let comp = color.cgColor.components?.map { x -> CGFloat in
            let y = x - 15/255
            return y > 0 ? y : 0
        }
        let color2 = CGColor(colorSpace: color.cgColor.colorSpace!, components: comp!) ?? color.cgColor
        
        let gradientView = GradientView()
        gradientView.isUserInteractionEnabled = false
        gradientView.gradientLayer.colors = [color.cgColor, color2]
        gradientView.gradientLayer.gradient = GradientPoint.topBottom.draw()
        backgroundColor = .clear
        insertSubview(gradientView, at: 0)
        
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
