//
//  AppDelegate.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 07.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//

import Cocoa
import SWXMLHash

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
   
    let SERVER_HOST:String = "127.0.0.1"
    let SERVER_PORT:Int32 = 49152
    
    // controllers
    var tcpClient: TCPListener?
    var midiListener: MidiListener?
    var viewController:ViewController?
    
    // focusrite stuff
    var clientId: String = ""
    var devices: [String : Device] = [:]
    
    // various vars
    var isMidiMapping:Bool = false
    var selectedMidiMapId = ""
    var selectedMidiMapIndex = -1
    var selectedDevice: Device?
    var selectedMix: Mix?
    var selectedHardwareOutput: HardwareOutput?
    
    override init(){
        super.init()
        tcpClient = TCPListener(address: SERVER_HOST, port: SERVER_PORT)
        midiListener = MidiListener()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        tcpClient?.start()
        midiListener?.start()
        
        UserDefaults.standard.register(defaults: ["volumeLimit" : "0"])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func getStereoMixes() -> [Mix] {
        let stereoOutputs = getStereoHardwareOutputs()
        var stereoMixes: [Mix] = []
        for stereoOutput in stereoOutputs{
            let mix:Mix? = stereoOutput.source.object
            stereoMixes.append(mix!)
        }
        return stereoMixes
    }
    
    func getStereoHardwareOutputs() -> [HardwareOutput] {
        let stereoOutputs = appDelegate.selectedDevice?.getStereoOutputs()
        if (stereoOutputs != nil){
            return stereoOutputs!
        }
        return []
    }
    
    func onMidiMessageReceived (midiMessage: MidiMessage){
        if(selectedDevice != nil){
            if(isMidiMapping){
                if (selectedDevice?.mixes != nil){
                    var ids: [String] = []
                    let midiMapAllMixes:Bool = UserDefaults.standard.bool(forKey: "midiMapAllMixes")
                   
                    if(midiMapAllMixes){
                        for mix in getStereoMixes(){
                            let availableGains:Array<GainMeter> = mix.getAvailableGains(selectedHarwareOutput: selectedHardwareOutput)
                            
                            if(availableGains.indices.contains(selectedMidiMapIndex)){
                                ids.append(availableGains[selectedMidiMapIndex].gain.id)
                            }
                        }
                    }else{
                        guard let mix:Mix = getSelectedMix() else {return}
                        
                        let availableGains:Array<GainMeter> = mix.getAvailableGains(selectedHarwareOutput: selectedHardwareOutput)
                        
                        if(availableGains.indices.contains(selectedMidiMapIndex)){
                            ids.append(availableGains[selectedMidiMapIndex].gain.id)
                        }
                    }
                    selectedDevice?.setMidiMap(ids: ids, midiMessage: midiMessage)
                }
                
                viewController?.setMidiMapping();
            }else{
                let midiItems: [Item]? = selectedDevice?.findItems(midiMessage: midiMessage)
                if(midiItems != nil){
                    for midiItem in midiItems! {
                        tcpClient?.sendVolMessage(item: midiItem, volume: midiMessage.value)
                    }
                }
            }
        }
    }
    
    func onDeviceArrival(xml: XMLIndexer) -> Device?{
        guard let device:Device = Device(xml: xml) else {return nil}
        selectedDevice = device
        selectedHardwareOutput = device.hardwareOutputs[0]
        devices[device.id] = device
        viewController?.onDeviceArrival(device: device)
        
        return device
    }
    
    func getSelectedMix() -> Mix? {
        return appDelegate.selectedHardwareOutput?.source.object
    }
    
    func onDeviceRemoval(xml:XMLIndexer){
        selectedDevice = nil
        selectedMix = nil
        selectedHardwareOutput = nil
        let id = (xml["device-removal"].element?.attribute(by: "id")?.text)!
        devices.removeValue(forKey: id)
        
        viewController?.onDeviceRemoval()
    }
    
    func onDeviceValues(valuesXML:XMLIndexer){
        let id = (valuesXML.element?.attribute(by: "devid")?.text)!
        guard let device = devices[id] else { return }
        let items = device.setValues(valuesXML: valuesXML)
        viewController?.onDeviceValues(items: items)
    }
    
    func onConnectionChange(connected:Bool){
        viewController?.setConnected(connected: connected)
    }
    
    func onApproveChanged(approved:Bool){
        viewController?.setApproved(approved: approved)
    }

}

