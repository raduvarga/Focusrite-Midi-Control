//
//  CombinedInput.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 14.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//

import Cocoa

@objc (CombinedInputs)
class GainMeter: NSObject {
    
    @objc var gain: MidiMappableItem = MidiMappableItem()
    @objc var name: String?
    @objc var available: Bool = false
    @objc var inputNr: Int = -1
    
    init (mixInput: MixInput, mixerInput: MixerInput){
        super.init()
        
        self.gain = mixInput.gain
        let hardwareInput = mixerInput.source.object
        if (hardwareInput != nil){
            self.available = true
            let name = mixerInput.isStereo() ? hardwareInput?.stereoName : hardwareInput?.name
            self.name = (hardwareInput?.nickname.value)! + " ("  + name! + ")"
            self.inputNr = (hardwareInput?.inputNr)!
        }
    }
    
    init (mixGain: MidiMappableItem){
        super.init()
        
        self.gain = mixGain
        self.name = "Mix Gain"
        self.inputNr = 9999
        self.available = true
    }
    
    func setRow(row: Int){
        gain.row = row
    }
}
