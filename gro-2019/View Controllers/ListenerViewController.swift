//
//  ListenerViewController.swift
//  Helper Keyboard
//
//  Created by Victor Zhong on 11/2/19.
//  Copyright © 2019 Victor Zhong. All rights reserved.
//

import UIKit
import Speech

protocol ListenerViewDelegate: SpeechHelperDelegate {

    func sendAlert(title: String, message: String)
    func updateText(text: String)

}

class ListenerViewController: UIViewController {

    weak var delegate: ListenerViewDelegate?

    private var speechHelper: SpeechHelper?

    private var speechString: String?

    private var isRecording = false

    private lazy var recordButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("Record", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(recordButtonToggled), for: .touchUpInside)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [spokenHeadlineLabel,
                                                   spokenTextLabel,
                                                   suggestionHeadlineLabel,
                                                   suggestionTextLabel,
                                                   recordButton])
        stack.spacing = 16
        stack.axis = .vertical
        stack.alignment = .center
        return stack
    }()

    private lazy var spokenHeadlineLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.numberOfLines = 1
        label.text = "Spoken Text"
        return label
    }()

    private lazy var spokenTextLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.numberOfLines = 3
        label.text = "Start speaking"
        return label
    }()

    private lazy var suggestionHeadlineLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.numberOfLines = 1
        label.text = "Suggestion:"
        label.isHidden = true
        return label
    }()

    private lazy var suggestionTextLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.numberOfLines = 3
        label.textColor = .gray
        label.text = "Suggestions go here"
        label.isHidden = true
        return label
    }()

    private lazy var containerView: UIView = {
        let view = UIView(forAutoLayout: ())
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDesign()
        setupListener()
    }

    @objc func recordButtonToggled() {
        if isRecording {
            speechHelper?.cancelRecording()
        } else {
            isRecording = !isRecording
            recordButton.setTitle("Stop Recording", for: .normal)
            speechHelper?.recordAndRecognizeSpeech()
            suggestionHeadlineLabel.isHidden = false
            suggestionTextLabel.isHidden = false
        }
    }
    
}

private extension ListenerViewController {

    func setupDesign() {
        view.addSubview(containerView)
        containerView.autoSetDimension(.height, toSize: view.frame.height * 0.8)
        containerView.autoSetDimension(.width, toSize: view.frame.width * 0.8)
        containerView.autoCenterInSuperview()

        containerView.addSubview(stackView)
        stackView.autoAlignAxis(toSuperviewAxis: .horizontal)
        stackView.autoPinEdge(.leading, to: .leading, of: view, withOffset: 32)
        stackView.autoPinEdge(.trailing, to: .trailing, of: view, withOffset:-32)
    }

    func setupListener() {
        speechHelper = SpeechHelper(delegate: self)
    }

}

extension ListenerViewController: SpeechHelperDelegate {

    func sendAlert(title: String, message: String) {
        delegate?.sendAlert(title: title, message: message)
    }

    func updateText(text: String) {
        speechString = text
        spokenTextLabel.text = speechString ?? ""
        print("*** \(speechString ?? "")")
    }

    func recordingCanceled() {
        delegate?.updateText(text: speechString ?? "")
        self.dismiss(animated: true, completion: nil)
    }

}
