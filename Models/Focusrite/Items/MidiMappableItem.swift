//
//  MidiMappableItem.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 09.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//

import Cocoa
import SWXMLHash

@objc (MidiMappableItem)
class MidiMappableItem: ValueItem {
    @objc var midiMapMessage: MidiMessage = MidiMessage()
    
    override init(){
        super.init()
    }
    
    override init(xml: XMLIndexer, parentDevice: Device){
        super.init(xml: xml, parentDevice: parentDevice)
    }
}
