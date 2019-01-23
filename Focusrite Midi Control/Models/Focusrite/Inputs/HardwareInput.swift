//
//  HardwareInput.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 10.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//

import Cocoa
import SWXMLHash

@objc (HardwareInput)
class HardwareInput: Item {
    @objc var available: ValueItem = ValueItem()
    @objc var meter: ValueItem = ValueItem()
    @objc var nickname: ValueItem = ValueItem()
    
    @objc var name: String? = ""
    @objc var stereoName: String? = ""
    
    @objc var inputNr: Int = -1
    
    override init(){
        super.init()
    }
    
    override init(xml: XMLIndexer, parentDevice: Device){
        super.init(xml: xml, parentDevice: parentDevice)
        available = ValueItem(xml: xml["available"], parentDevice: parentDevice)
         nickname =  ValueItem(xml: xml["nickname"], parentDevice: parentDevice)
        
        name = xml.element?.value(ofAttribute: "name")
        stereoName = xml.element?.value(ofAttribute: "stereo-name")
    }
}

@objc (AnalogueInput)
class AnalogueInput: HardwareInput {
}

@objc (SpdifInput)
class SpdifInput: HardwareInput {
}

@objc (AdatInput)
class AdatInput: HardwareInput {
}

@objc (DanteInput)
class DanteInput: HardwareInput {
}

@objc (PlaybackInput)
class PlaybackInput: HardwareInput {
}
