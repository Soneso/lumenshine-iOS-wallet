//
//  ReLoginViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/30/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol ReLoginViewProtocol {
    func present(error: ServiceError) -> Bool
}

class ReLoginViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: LoginViewModelType
    
    // MARK: - UI properties
    fileprivate let headerBar = ToolbarHeader()
    fileprivate let scrollView = UIScrollView()
    fileprivate let scrollContentView = UIView()
    
    fileprivate var contentView: ReLoginViewProtocol?
    
    init(viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        self.contentView = ReLoginHomeView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        showHome(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func setupContentView(_ contentView: UIView, animated: Bool = true) {
        if animated {
            let animation = CATransition()
            animation.duration = 0.3
            animation.type = kCATransitionReveal
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            contentView.layer.add(animation, forKey: kCATransitionReveal)
        }
        
        if let oldContent = self.contentView as? UIView {
            oldContent.removeFromSuperview()
        }
        scrollContentView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView = contentView as? ReLoginViewProtocol
    }
    
    func showHome(animated: Bool = true) {
        let contentView = ReLoginHomeView(viewModel: viewModel)
        contentView.delegate = self
        setupContentView(contentView, animated: animated)
    }
    
    func showFingerprint() {
        let contentView = ReLoginFingerView(viewModel: viewModel)
        contentView.delegate = self
        setupContentView(contentView)
    }
}

// MARK: - Actions
extension ReLoginViewController {
    @objc
    func changeAccountAction(sender: UIButton) {
        viewModel.showLoginForm()
    }
    
}

extension ReLoginViewController: ToolbarHeaderDelegate {
    func toolbar(_ toolbar: ToolbarHeader, didSelectAt index: Int) {
        viewModel.barItemSelected(at: index)
    }
}

extension ReLoginViewController: ReLoginViewDelegate {
    func didTapSubmitButton(password: String, tfaCode: String?) {
        showActivity()
        viewModel.loginStep1(email: "", password: password, tfaCode: tfaCode) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideActivity(completion: {
                    switch result {
                    case .success: break
                    case .failure(let error):
                        _ = self?.contentView?.present(error: error)
                    }
                })
            }
        }
    }
}

fileprivate extension ReLoginViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.lightGray)
        prepareHeader()
        prepareCopyright()
        prepareContentView()
    }
    
    func prepareHeader() {
        headerBar.delegate = self
        headerBar.setTitle(viewModel.headerTitle)
        headerBar.setDetail(viewModel.headerDetail)
        headerBar.setItems(viewModel.barItems, selectedAt: 1)
        
        view.addSubview(headerBar)
        headerBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
    }
    
    func prepareContentView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerBar.snp.bottom)
            make.bottom.left.right.equalToSuperview()
        }
        
        scrollContentView.cornerRadiusPreset = .cornerRadius2
        scrollContentView.depthPreset = .depth2
        scrollContentView.backgroundColor = Stylesheet.color(.white)
        
        let topOffset = UIScreen.main.scale > 2 ? 25 : 10
        scrollView.addSubview(scrollContentView)
        scrollContentView.snp.makeConstraints { make in
            make.top.equalTo(topOffset)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-50)
            make.width.equalTo(view).offset(-20)
        }
    }
    
    func prepareCopyright() {
        let imageView = UIImageView(image: R.image.soneso())
        imageView.backgroundColor = Stylesheet.color(.clear)
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(-10)
            make.centerX.equalToSuperview()
        }
        
        let label = UILabel()
        label.text = R.string.localizable.powered_by().uppercased()
        label.textColor = Stylesheet.color(.gray)
        label.font = R.font.encodeSansRegular(size: 8.5)
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(imageView.snp.top).offset(-5)
        }
    }
}

