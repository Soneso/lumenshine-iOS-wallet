//
//  VerificationViewController.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/28/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import stellarsdk
import UIKit

class VerificationViewController: UIViewController {
    
    fileprivate let collectionView: UICollectionView
    fileprivate let textView = UITextView()
    fileprivate let progressView = UIProgressView()
    fileprivate let quicktypeView = UIView()
    fileprivate let questionHolderView = UIView()
    fileprivate let questionTitleLabel = UILabel()
    fileprivate let questionSubtitleLabel = UILabel()
    
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
    var suggestions: [String] = []
    var questionWords: [String] = []
    var currentWord: String = ""
    var mnemonic: String = ""
    
    required init?(coder aDecoder: NSCoder) {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        super.init(coder: aDecoder)
    }
    
    init(type: VerificationType, mnemonic: String) {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
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
            setPin(mnemonic: mnemonicString)
        }
    }
}

extension VerificationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        clearSuggestions(reload: false)
        
        let subString = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        
        if let lastWord = getWords(string: String(subString)).last {
            suggestions.append(contentsOf: getAutocompleteSuggestions(userText: lastWord))
        }
        
        collectionView.reloadData()
        
        return true
    }
}

extension VerificationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WordSuggestionCell.cellIdentifier, for: indexPath) as! WordSuggestionCell
        cell.setTitle(suggestions[indexPath.row])
        return cell
    }
}

extension VerificationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let suggestion = suggestions[indexPath.row]
        var words = getWords(string: textView.text)
        if words.count > 0 {
            words.removeLast()
        }
        words.append(suggestion)
        
        textView.text = words.joined(separator: " ")
        
        if type != .questions {
            textView.text.append(" ")
        }
        
        clearSuggestions(reload: true)
    }
}

extension VerificationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width / 3, height: collectionView.frame.size.height)
    }
}

fileprivate extension VerificationViewController {
    func prepareViews() {
        prepareQuestionHolder()
        prepareTextView()
        
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
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(questionHolderView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(textViewHeight)
        }
    }
    
    func setupView() {
        collectionView.register(WordSuggestionCell.self, forCellWithReuseIdentifier: WordSuggestionCell.cellIdentifier)
        
        switch type {
        case .confirmation:
            navigationItem.title = "Re-enter Your Phrase"
            
            questionViewHeight = 0.0
            textViewHeight = defaultTextViewHeight
        case .questions:
            questionViewHeight = defaultQuestionViewHeight
            textViewHeight = questionTextViewHeight
            
            setQuestion(animated: false)
        default:
            navigationItem.title = "Enter Recovery Phrase"
            
            questionViewHeight = 0.0
            textViewHeight = defaultTextViewHeight
        }
        
        let image = UIImage(named:"close")
        let leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        textView.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0);
        textView.inputAccessoryView = quicktypeView
        
        progressView.backgroundColor = Stylesheet.color(.darkGray)
        textView.textColor = Stylesheet.color(.darkGray)
        questionHolderView.backgroundColor = Stylesheet.color(.lightGray)
        questionTitleLabel.textColor = Stylesheet.color(.darkGray)
        questionTitleLabel.textAlignment = .center
        questionSubtitleLabel.textColor = Stylesheet.color(.darkGray)
        questionSubtitleLabel.textAlignment = .center
        view.backgroundColor = Stylesheet.color(.lightGray)
    }
    
    func getWords(string: String) -> [String] {
        let components = string.components(separatedBy: .whitespacesAndNewlines)
        
        return components.filter { !$0.isEmpty }
    }
    
    func clearSuggestions(reload: Bool) {
        suggestions.removeAll()
        
        if reload {
            collectionView.reloadData()
        }
    }
    
    func getAutocompleteSuggestions(userText: String) -> [String]{
        var possibleMatches: [String] = []
        let wordList: WordList = .english
        
        for item in wordList.words {
            let myString:NSString! = item as NSString
            let substringRange :NSRange! = myString.range(of: userText)
            
            if (substringRange.location == 0) {
                possibleMatches.append(item)
            }
        }
        return possibleMatches.enumerated().flatMap{ $0.offset < 3 ? $0.element : nil }
    }
    
    func validateAnswer() {
        if textView.text == currentWord {
            if questionsAnswered == 4 {
                setPin(mnemonic: mnemonic)
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
            questionWords = mnemonic.components(separatedBy: " ")
        }
        
        let randomIndex = Int(arc4random_uniform(UInt32(questionWords.count)))
        currentWord = questionWords[randomIndex]
        
        if let indexOfWord = mnemonic.components(separatedBy: " ").index(of: currentWord) {
            questionTitleLabel.text = "What was the word \(String(describing: indexOfWord + 1))?"
            questionWords.remove(at: randomIndex)
            questionsAnswered += 1
            
            setProgress(animated: animated)
        }
    }
    
    func setProgress(animated: Bool) {
        progressView.progress = Float(questionsAnswered/totalQuestionCount)
        
        navigationItem.title = "Question \(questionsAnswered) of \(totalQuestionCount)"
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func setPin(mnemonic: String) {
        //        let pinViewController = PinViewController(pin: nil, mnemonic: mnemonic)
        //
        //        navigationController?.pushViewController(pinViewController, animated: true)
    }
}

