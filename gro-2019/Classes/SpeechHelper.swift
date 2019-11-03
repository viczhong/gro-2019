//
//  SpeechHelper.swift
//  Helper Keyboard
//
//  Created by Victor Zhong on 11/2/19.
//  Copyright © 2019 Victor Zhong. All rights reserved.
//

import Foundation
import Speech

protocol SpeechHelperDelegate: AnyObject {

    func sendAlert(title: String, message: String)
    func updateText(text: String)
    func recordingCanceled()

}

extension SpeechHelperDelegate {

     func recordingCanceled() { }

}

class SpeechHelper {

    weak var delegate: SpeechHelperDelegate?

    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false

    init(delegate: SpeechHelperDelegate?) {
        self.delegate = delegate
    }

    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            delegate?.sendAlert(title: "Speech Recognizer Error", message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            delegate?.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            delegate?.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { [weak self] result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self?.delegate?.updateText(text: bestString)
            } else if let error = error {
                self?.delegate?.sendAlert(title: "Speech Recognizer Error", message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }

    func cancelRecording() {
        recognitionTask?.finish()
        recognitionTask = nil

        // stop audio
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.inputNode.reset()
        delegate?.recordingCanceled()
    }

}

