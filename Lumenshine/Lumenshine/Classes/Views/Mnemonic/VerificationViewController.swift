//
//  VerificationViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/28/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import stellarsdk

protocol VerificationViewControllerDelegate {
    func verification(_ viewController:VerificationViewController, didFinishWithSuccess success: Bool)
}

class VerificationViewController: UIViewController {
    
    fileprivate let textView = UITextView()
    fileprivate let progressView = UIProgressView()
    fileprivate let questionHolderView = UIView()
    fileprivate let questionTitleLabel = UILabel()
    fileprivate let questionSubtitleLabel = UILabel()
    fileprivate let nextButton = FlatButton()
    
    fileprivate var textViewHeight: CGFloat = 0
    fileprivate var questionViewHeight: CGFloat = 0
    
    public enum VerificationType {
        case recovery
        case confirmation
        case questions
    }
    
    let defaultQuestionViewHeight: CGFloat = 88.0
    let defaultTextViewHeight: CGFloat = 150.0
    let questionTextViewHeight: CGFloat = 48.0
    let totalQuestionCount = 4
    var questionsAnswered = 0
    var progressWidth: CGFloat {
        return UIScreen.main.bounds.size.width / CGFloat(totalQuestionCount)
    }
    
    var type: VerificationType = .recovery
    var questionWords: [String] = []
    var randomIndices: [Int] = []
    var mnemonic: String = ""
    
    var delegate: VerificationViewControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(type: VerificationType, mnemonic: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.type = type
        self.mnemonic = mnemonic
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        prepareViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    
    
    @objc
    func dismissView() {
        view.endEditing(true)
        delegate?.verification(self, didFinishWithSuccess: false)
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func nextButtonSelected() {
        switch type {
        case .questions:
            validateAnswer()
        default:
            guard var mnemonicString = textView.text, !mnemonicString.isEmpty else {
                return
            }
            
            let lastCharater = mnemonicString.last
            if lastCharater == " " {
                mnemonicString = String(mnemonicString.dropLast())
            }
//            setPin(mnemonic: mnemonicString)
        }
    }
}

extension VerificationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}

fileprivate extension VerificationViewController {
    func prepareViews() {
        prepareQuestionHolder()
        prepareTextView()
        prepareNextButton()
    }
    
    func prepareQuestionHolder() {
        view.addSubview(questionHolderView)
        questionHolderView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(questionViewHeight)
        }
        
        questionHolderView.addSubview(questionTitleLabel)
        questionTitleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        questionHolderView.addSubview(questionSubtitleLabel)
        questionSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(questionTitleLabel.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
        }
        
        questionHolderView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.equalTo(questionSubtitleLabel.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func prepareTextView() {
        textView.delegate = self
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(questionHolderView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(textViewHeight)
        }
    }
    
    func prepareNextButton() {
        nextButton.title = R.string.localizable.next()
        nextButton.addTarget(self, action: #selector(nextButtonSelected), for: .touchUpInside)
        nextButton.titleColor = Stylesheet.color(.white)
        nextButton.backgroundColor = Stylesheet.color(.cyan)
        
        nextButton.frame = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: 50))
        
//        view.addSubview(nextButton)
//        nextButton.snp.makeConstraints { make in
//            make.bottom.left.right.equalToSuperview()
//            make.height.equalTo(50)
//        }
    }
    
    func setupView() {
        switch type {
        case .confirmation:
            navigationItem.titleLabel.text = "Re-enter Your Phrase"
            
            questionViewHeight = 0.0
            textViewHeight = defaultTextViewHeight
        case .questions:
            questionViewHeight = defaultQuestionViewHeight
            textViewHeight = questionTextViewHeight
            randomIndices = generateRandomIndices()
            
            setQuestion(animated: false)
        default:
            navigationItem.titleLabel.text = "Enter Recovery Phrase"
            
            questionViewHeight = 0.0
            textViewHeight = defaultTextViewHeight
        }
        
        let icon = Icon.close?.tint(with: Stylesheet.color(.white))
        let leftBarButtonItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        
        textView.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0);
        textView.inputAccessoryView = nextButton
        
        progressView.progressTintColor = Stylesheet.color(.cyan)
        progressView.trackTintColor = Stylesheet.color(.lightGray)
        textView.textColor = Stylesheet.color(.darkGray)
//        questionHolderView.backgroundColor = Stylesheet.color(.lightGray)
        questionTitleLabel.textColor = Stylesheet.color(.darkGray)
        questionTitleLabel.textAlignment = .center
        questionSubtitleLabel.textColor = Stylesheet.color(.darkGray)
        questionSubtitleLabel.textAlignment = .center
        view.backgroundColor = Stylesheet.color(.white)
    }
    
    func getWords(string: String) -> [String] {
        let components = string.components(separatedBy: .whitespacesAndNewlines)
        
        return components.filter { !$0.isEmpty }
    }
    
    func validateAnswer() {
        if let index = Int(textView.text),
            index-1 == randomIndices[questionsAnswered-1] {
            if questionsAnswered == 4 {
                questionsAnswered += 1
                setProgress(animated: true)                
                dismiss(animated: true, completion: {
                    self.delegate?.verification(self, didFinishWithSuccess: true)
                })
            } else {
                textView.text = ""
                setQuestion(animated: true)
            }
        } else {
            textView.textColor = UIColor.red
            textView.shake()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.textView.text = ""
                self.textView.textColor = Stylesheet.color(.darkGray)
            }
        }
    }
    
    func setQuestion(animated: Bool) {
        if questionWords.count == 0 {
            questionWords = mnemonic.components(separatedBy:" ")
        }
        
        let currentWord = questionWords[randomIndices[questionsAnswered]]
        
        questionTitleLabel.text = "What was the index of \"\(currentWord)\"?"
        questionsAnswered += 1
        
        setProgress(animated: animated)
    }
    
    func setProgress(animated: Bool) {
        progressView.progress = Float(questionsAnswered-1)/Float(totalQuestionCount)
        
        navigationItem.titleLabel.text = "Question \(questionsAnswered) of \(totalQuestionCount)"
    }
    
    func generateRandomIndices() -> [Int] {
        if questionWords.count == 0 {
            questionWords = mnemonic.components(separatedBy: " ")
        }
        var numbers: [Int] = []
        for _ in 1...totalQuestionCount {
            var n: Int
            repeat {
                n = Int(arc4random_uniform(UInt32(questionWords.count)))
            } while numbers.contains(n)
            numbers.append(n)
        }
        return numbers
    }
}

