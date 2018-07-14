//
//  Device.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 08.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//

import Cocoa
import SWXMLHash

@objc (Device)
class Device: NSObject {
    @objc var id: String = ""
    @objc var model: String = ""
    @objc var mixes: Array<Mix> = []
    @objc var mixerInputs: Array<MixerInput> = []
    @objc var hardwareInputs: Array<HardwareInput> = []
    @objc var hardwareOutputs: Array<HardwareOutput> = []
    
    // Very handy dictionary. We keep here a flattened list of all the
    // items which we can access directly via their id to update their values.
    // Updating values here in the dictionary also updates the values in the
    // nested lists (such as mixes, mixerInputs, etc), because the objects
    // are
    @objc var items: [String : Item] = [:]
    // list of midi mappings
    @objc var midiMaps: [String : String] = [:]
    
    init(xml: XMLIndexer){
        super.init()
        
        id = (xml.element?.attribute(by: "id")?.text)!;
        model = (xml.element?.attribute(by: "model")?.text)!;
        createMixes(xml: xml["mixer"]["mixes"])
        createMixerInputs(xml: xml["mixer"]["inputs"])
        createHardwareInputs(xml: xml["inputs"])
        createHardwareOutputs(xml: xml["outputs"])
        recreateMidiMaps()
    }
    
    func createHardwareInputs(xml: XMLIndexer){
        xml["analogue"].all.map { xmlItem in
            let input: AnalogueInput = AnalogueInput(xml: xmlItem, parentDevice: self)
            hardwareInputs.append(input)
        }
        
        xml["spdif-rca"].all.map { xmlItem in
            let input: SpdifInput = SpdifInput(xml: xmlItem, parentDevice: self)
            hardwareInputs.append(input)
        }
        xml["adat"].all.map { xmlItem in
            let input: AdatInput = AdatInput(xml: xmlItem, parentDevice: self)
            hardwareInputs.append(input)
        }
        xml["playback"].all.map { xmlItem in
            let input: PlaybackInput = PlaybackInput(xml: xmlItem, parentDevice: self)
            hardwareInputs.append(input)
        }
        
        for i in 1...hardwareInputs.count-1 {
            hardwareInputs[i].inputNr = i
        }
    }
    
    func createHardwareOutputs(xml: XMLIndexer){
        xml["analogue"].all.map { xmlItem in
            let input: AnalogueOutput = AnalogueOutput(xml: xmlItem, parentDevice: self)
            hardwareOutputs.append(input)
        }
        xml["spdif-rca"].all.map { xmlItem in
            let input: SpdifOutput = SpdifOutput(xml: xmlItem, parentDevice: self)
            hardwareOutputs.append(input)
        }
    }
    
    func createMixerInputs(xml: XMLIndexer){
        xml["input"].all.map { xmlItem in
            let input: MixerInput = MixerInput(xml: xmlItem, parentDevice: self)
            mixerInputs.append(input)
        }
    }
    
    func createMixes(xml: XMLIndexer){
        xml["mix"].all.map { xmlItem in
            let mix: Mix = Mix(xml: xmlItem, parentDevice: self)
            mixes.append(mix)
        }
    }
    
    func getStereoOutputs() -> Array<HardwareOutput> {
        return hardwareOutputs.filter({$0.isStereo()})
    }
    
    func recreateMidiMaps(){
        let midiMapsPreferences = UserDefaults.standard.dictionary(forKey: "midiMaps")
        if (midiMapsPreferences != nil){
            midiMaps = midiMapsPreferences as! [String : String]
            
            for midiMap in midiMaps {
                let midiStr:String = midiMap.key
                let id:String = midiMap.value
                
                let item:Item? = items[id]
                if (item != nil && item is MidiMappableItem){
                    let midiItem: MidiMappableItem = item as! MidiMappableItem
                    midiItem.midiMapMessage = MidiMessage(midiStr: midiStr)
                }
            }
        }
    }
    
    func setValues(valuesXML: XMLIndexer) -> [Item]{
        var changedItems:[Item] = []
        
        valuesXML["item"].all.map {xmlItem in
            let id = (xmlItem.element?.attribute(by: "id")?.text)!
            let item = items[id]
            if(item != nil){
                changedItems.append(item!)
                let value = (xmlItem.element?.attribute(by: "value")?.text)!
                item?.setValue(value: value)
            }
        }
        
        return changedItems
    }
    
    func setMidiMap(id: String, midiMessage: MidiMessage){
        let item:Item? = items[id]
        if(item != nil && item is MidiMappableItem){
            // remove old midi mapping
            let midiStr = midiMessage.asStr
            removeMidiMap(midiStr: midiStr)
            
            let midiItem: MidiMappableItem = (item as! MidiMappableItem)
            midiItem.midiMapMessage.copy(midiMessage: midiMessage)
            midiMaps[midiMessage.asStr] = midiItem.id
            
            UserDefaults.standard.set(midiMaps, forKey: "midiMaps")
        }
    }
    
    func removeMidiMap(midiStr: String){
        let oldMappingId = midiMaps[midiStr]
        if(oldMappingId != nil){
            let oldMappingItem: Item? = items[oldMappingId!]
            (oldMappingItem as! MidiMappableItem).midiMapMessage.clear()
            midiMaps.removeValue(forKey: midiStr)
        }
    }
    
    func removeAllMidiMaps(){
        for midiMap in midiMaps {
            removeMidiMap(midiStr: midiMap.key)
        }
    }
    
    func findItem(midiMessage: MidiMessage) -> Item?{
        let id:String? = midiMaps[midiMessage.asStr]
        if (id != nil){
            return items[id!]
        }
        return nil
    }
}
