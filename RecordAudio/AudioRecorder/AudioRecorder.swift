//
//  AudioRecorder.swift
//  RecordAudio
//
//  Created by Joe Henke on 9/22/22.
//

import Foundation
import AVFoundation

protocol AudioRecorderDelegate: AnyObject {
    func didAllowRecordingPermission()
    func didDenyRecordingPermission()
    func showError(_ errorMsg: String)
    func recordingDidStart()
    func recordingDidFinish(_ success: Bool)
    func playerDidFinish()
    func playerDidStart()
}

class AudioRecorder: NSObject {
    private(set) weak var delegate: AudioRecorderDelegate?
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?
    
    let audioSettings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    init ( delegate: AudioRecorderDelegate ) {
        super.init()
        self.delegate = delegate
        initRecordingSession()
    }
    
    func record(_ filename: String) {
        guard audioRecorder == nil else {
            finishRecording(success: true)
            return
        }
        
        let audioFilename = getFileURL(filename)
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: audioSettings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            delegate?.recordingDidStart()
        } catch {
            delegate?.showError("failed to Record")
            finishRecording(success: false)
        }
    }
    
    func play(_ filename: String) {
        let audioFilename = getFileURL(filename)
        preparePlayer(filename)
        audioPlayer?.play()
    }
    
    func stop() {
        audioPlayer?.stop()
        delegate?.playerDidFinish()
    }
    
    private func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        delegate?.recordingDidFinish(success)
    }
    
    private func preparePlayer(_ filename: String) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileURL(filename) as URL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 10.0
        } catch let error1 as NSError {
            delegate?.showError(error1.description)
            audioPlayer = nil
        }
    }

    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func getFileURL(_ filename: String) -> URL {
        let path = getDocumentsDirectory().appendingPathComponent(filename)
        return path as URL
    }
    
    private func initRecordingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            recordingSession?.requestRecordPermission() { [weak self] allowed in
                if allowed {
                    self?.delegate?.didAllowRecordingPermission()
                } else {
                    self?.delegate?.didDenyRecordingPermission()
                }
            }
        } catch {
            delegate?.showError("failed to Record")
        }
    }
    
    
}


extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}

extension AudioRecorder: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.playerDidFinish()
    }
}
