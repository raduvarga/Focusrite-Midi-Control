//
//  Mix.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 09.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//

import Cocoa
import SWXMLHash

@objc (Mix)
class Mix: Item {
    @objc dynamic var name: String = ""
    @objc dynamic var stereoName: String = ""
    
    @objc dynamic var meter: MidiMappableItem?
    @objc dynamic var mixInputs: Array<MixInput> = []
    @objc dynamic var availableGains: Array<GainMeter> = []
    
    override init(xml: XMLIndexer, parentDevice: Device){
        super.init(xml: xml, parentDevice: parentDevice)
        
        name = (xml.element?.value(ofAttribute: "name"))!
        stereoName = (xml.element?.value(ofAttribute: "stereo-name"))!
        meter = MidiMappableItem(xml: xml["meter"], parentDevice: parentDevice)
        createInputs(xml: xml, parentDevice: parentDevice)
    }
    
    func createInputs(xml: XMLIndexer, parentDevice: Device){
        xml["input"].all.map { xmlInput in
            let input: MixInput = MixInput(xml: xmlInput, parentDevice: parentDevice)
            mixInputs.append(input)
        }
    }
    
    func createGains(selectedHarwareOutput: HardwareOutput?){
        if (parentDevice?.mixerInputs != nil){
            for i in 0...(mixInputs.count-1) {
                let mixerInput = parentDevice?.mixerInputs[i]
                let mixInput = mixInputs[i]
                let combinedInput = GainMeter(mixInput: mixInput, mixerInput: mixerInput!)
                availableGains.append(combinedInput)
            }
        }
        
        if (selectedHarwareOutput != nil){
            availableGains.append(GainMeter(mixGain: selectedHarwareOutput!.gain))
        }
    }
    
    func getAvailableGains (selectedHarwareOutput: HardwareOutput?) -> Array<GainMeter> {
       if (availableGains == []){
            createGains(selectedHarwareOutput: selectedHarwareOutput)
       }
        
       availableGains = availableGains.filter({$0.available})
       availableGains = availableGains.sorted(by: { $0.inputNr < $1.inputNr })
       return availableGains
    }
}
