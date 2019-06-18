//
//  ReLoginViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol ReLoginViewProtocol {
    func present(error: ServiceError) -> Bool
    func setTFACode(_ tfaCode: String)
}

class ReLoginViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: ReLoginViewModel
    
    // MARK: - UI properties
    fileprivate let headerBar = ToolbarHeader()
    fileprivate let scrollView = UIScrollView()
    fileprivate let scrollContentView = UIView()
    
    fileprivate var contentView: ReLoginViewProtocol?
    
    init(viewModel: ReLoginViewModel) {
        self.viewModel = viewModel
        //self.contentView = ReLoginHomeView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
        
        viewModel.reloadClosure = {
            DispatchQueue.main.async {
                self.headerBar.setItems(viewModel.barItems, selectedAt: 1)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        showHome(animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @objc
    func appWillEnterForeground(notification: Notification) {
        if UIPasteboard.general.hasStrings {
            if let tfaCode = UIPasteboard.general.string,
                tfaCode.count == 6,
                CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: tfaCode)) {
                contentView?.setTFACode(tfaCode)
            }
        }
    }
    
    func setupContentView(_ contentView: UIView, animated: Bool = true) {
        if animated {
            let animation = CATransition()
            animation.duration = 0.3
            animation.type = CATransitionType.reveal
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            contentView.layer.add(animation, forKey: CATransitionType.reveal.rawValue)
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
        showActivity(message: R.string.localizable.loading())
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

extension ReLoginViewController: ReLoginFingerViewDelegate {
    func didTapActivateButton(password: String, tfaCode: String?) {
        showActivity(message: R.string.localizable.loading())
        viewModel.loginStep1(email: "", password: password, tfaCode: tfaCode, checkSetup: false) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideActivity(completion: {
                    switch result {
                    case .success:                        
                        self?.showHome()
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
        
        scrollContentView.cornerRadiusPreset = .cornerRadius4
        scrollContentView.depthPreset = .depth3
        scrollContentView.backgroundColor = Stylesheet.color(.white)
        
        scrollView.addSubview(scrollContentView)
        scrollContentView.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-60)
            make.width.equalTo(view).offset(-30)
        }
    }
    
    func prepareCopyright() {
        let imageView = UIImageView(image: R.image.soneso())
        imageView.backgroundColor = Stylesheet.color(.clear)
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(-20)
            make.centerX.equalToSuperview()
        }
        
        let background = UIImageView(image: R.image.soneso_background())
        background.contentMode = .scaleAspectFit
        
        view.addSubview(background)
        background.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(headerBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(imageView.snp.top)
        }
    }
}
