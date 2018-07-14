//
//  HardwareInput.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 10.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//

import Cocoa
import SWXMLHash

@objc (HardwareOutput)
class HardwareOutput: NSObject {
    @objc var available: ValueItem = ValueItem()
    @objc var meter: ValueItem = ValueItem()
    @objc var nickname: ValueItem = ValueItem()
    var source: ObjectItem<Mix> = ObjectItem()
    @objc var stereo: ValueItem = ValueItem()
    @objc var gain: MidiMappableItem = MidiMappableItem()
    
    @objc var name: String = ""
    @objc var displayName: String = ""
    @objc var stereoName: String = ""
    @objc var row: Int = -1
    
    init(xml: XMLIndexer, parentDevice: Device){
        super.init()
        available = ValueItem(xml: xml["available"], parentDevice: parentDevice)
        meter =  ValueItem(xml: xml["meter"], parentDevice: parentDevice)
        nickname =  ValueItem(xml: xml["nickname"], parentDevice: parentDevice)
        source = ObjectItem(xml: xml["source"], parentDevice: parentDevice)
        stereo =  ValueItem(xml: xml["stereo"], parentDevice: parentDevice)
        gain =  MidiMappableItem(xml: xml["gain"], parentDevice: parentDevice)
        
        name = (xml.element?.value(ofAttribute: "name"))!
        stereoName = (xml.element?.value(ofAttribute: "stereo-name"))!
    }
    
    func isStereo() -> Bool {
        return (stereo.value == "true") && stereoName != ""
    }
}

@objc (Analogue)
class AnalogueOutput: HardwareOutput {
}

@objc (SpdifOutput)
class SpdifOutput: HardwareOutput {
}
