//
//  AudioRecorderViewController.swift
//  RecordAudio
//
//  Created by Joe Henke on 9/22/22.
//

import UIKit

class AudioRecorderViewController: UIViewController {
    var audioRecorder: AudioRecorder?
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!
    
    let audioFilename = "audioFile.m4a"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioRecorder = AudioRecorder(delegate: self)
        recordButton.addTarget(self, action: #selector(onRecord), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(onPlay), for: .touchUpInside)
    }
    
    @objc func onRecord(_ sender: UIButton) {
        audioRecorder?.record(audioFilename)
    }
    
    
    @objc func onPlay(_ sender: UIButton) {
        audioRecorder?.play(audioFilename)
    }
}


extension AudioRecorderViewController: AudioRecorderDelegate {
    func didAllowRecordingPermission() {
        recordButton.isEnabled = true
        playButton.isEnabled = false
        recordButton.setTitle("Tap to Record", for: .normal)
    }
    
    func didDenyRecordingPermission() {
        print("denied recording permission")
    }
    
    func showError(_ errorMsg: String) {
        print(errorMsg)
    }
    
    func recordingDidStart() {
        recordButton.setTitle("Tap to Stop", for: .normal)
        playButton.isEnabled = false
    }
    
    func recordingDidFinish(_ success: Bool) {
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
        }
        
        playButton.isEnabled = true
        recordButton.isEnabled = true
    }
    
    func playerDidStart() {
        recordButton.isEnabled = false
        playButton.setTitle("Stop", for: .normal)
    }
    
    func playerDidFinish() {
        playButton.setTitle("Play", for: .normal)
    }
}
