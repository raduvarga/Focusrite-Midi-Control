//
//  Input.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 09.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//

import Cocoa
import SWXMLHash

@objc (MixInput)
class MixInput: NSObject {
    @objc var gain: MidiMappableItem = MidiMappableItem()
    @objc var pan: MidiMappableItem = MidiMappableItem()
    @objc var mute: MidiMappableItem = MidiMappableItem()
    @objc var solo: MidiMappableItem = MidiMappableItem()
    
    override init(){
        super.init()
    }
    
    init(xml: XMLIndexer, parentDevice: Device){
        super.init()
        gain = MidiMappableItem(xml: xml["gain"], parentDevice: parentDevice)
        pan =  MidiMappableItem(xml: xml["pan"], parentDevice: parentDevice)
        mute = MidiMappableItem(xml: xml["mute"], parentDevice: parentDevice)
        solo = MidiMappableItem(xml: xml["solo"], parentDevice: parentDevice)
    }
}
