//
//  ViewController.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 07.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//

import Cocoa
import SWXMLHash

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate {
    
    let backgroundColor : CGColor = CGColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.0)
   
    @IBOutlet weak var mixLabel: NSTextField!
    @IBOutlet weak var connectedLabel: NSTextField!
    @IBOutlet weak var approvedLabel: NSTextField!
    @IBOutlet weak var deviceNameLabel: NSTextField!
    @IBOutlet weak var mixTableView: NSTableView!
    @IBOutlet weak var outputsTableView: NSTableView!
    @IBOutlet weak var creditsLabel: NSTextField!
    @IBOutlet weak var versionLabel: NSTextField!
    var appDelegate:AppDelegate = NSApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        
        appDelegate.viewController = self
        let appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.stringValue = "version: " + appVersion
    }
    
    override func awakeFromNib() {
        if self.view.layer != nil {
            self.view.layer?.backgroundColor = backgroundColor
        }
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
    }
    
    private func windowShouldClose(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    func getAvailableGains() -> [GainMeter] {
        let selectedMix:Mix? = appDelegate.getSelectedMix()
        if (selectedMix != nil){
            return selectedMix!.getAvailableGains(selectedHarwareOutput: appDelegate.selectedHardwareOutput)
        }
        return []
    }
    
    func getStereoHardwareOutputs() -> [HardwareOutput] {
        let stereoOutputs = appDelegate.selectedDevice?.getStereoOutputs()
        if (stereoOutputs != nil){
            return stereoOutputs!
        }
        return []
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func onResetMidiMappings(_ sender: Any) {
        if(appDelegate.selectedDevice != nil){
            UserDefaults.standard.set([:], forKey: "midiMaps")
            appDelegate.selectedDevice?.removeAllMidiMaps()
            mixTableView.reloadData()
        }
    }
    
    @IBAction func onStopMidiClick(_ sender: NSButton) {
        if(appDelegate.isMidiMapping){
            let myString = "Start Midi Map"
            let myAttribute = [ NSAttributedStringKey.foregroundColor: NSColor.black ]
            let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
            sender.attributedTitle = myAttrString
            mixTableView.reloadData()
            
            appDelegate.isMidiMapping = false
        }else{
            let myString = "Stop Midi Map"
            let myAttribute = [ NSAttributedStringKey.foregroundColor: NSColor.red ]
            let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
            sender.attributedTitle = myAttrString
            
            appDelegate.isMidiMapping = true
        }
    }
    
    func setMidiMapping(midiMapId: String, midiMessage: MidiMessage){
        DispatchQueue.main.async{
            if(self.mixTableView.selectedRow != -1){
                let nrRows: Int = self.mixTableView.numberOfRows - 1
                let rows: IndexSet =  IndexSet(0...nrRows)
                self.mixTableView.reloadData(forRowIndexes: rows, columnIndexes: [1])
            }
        }
    }
    func setConnected(connected:Bool){
        DispatchQueue.main.async{
            self.connectedLabel.textColor = connected ?  NSColor.green: NSColor.red
        }
    }
    func setApproved(approved:Bool){
        DispatchQueue.main.async{
            self.approvedLabel.textColor = approved ? NSColor.green: NSColor.red
        }
    }
    
    func onDeviceArrival(device: Device){
        DispatchQueue.main.async{
            self.deviceNameLabel.stringValue = device.model
            self.mixTableView.reloadData()
            self.outputsTableView.reloadData()
        }
    }
    
    func onDeviceRemoval(){
        DispatchQueue.main.async{
            self.outputsTableView.reloadData()
            self.mixTableView.reloadData()
            self.deviceNameLabel.stringValue = "No Device"
        }
    }
    
    func onDeviceValues(items: [Item]){
        for item in items{
            if(item.row != -1){
                DispatchQueue.main.async{
                    self.mixTableView.reloadData(forRowIndexes: [item.row], columnIndexes: [2])
                }
            }
        }
        DispatchQueue.main.async{
            if (self.outputsTableView.numberOfRows == 0){
                self.outputsTableView.reloadData()
            }else {
                let nrRows: Int = self.outputsTableView.numberOfRows - 1
                if (nrRows > 0){
                    let rows: IndexSet =  IndexSet(0...nrRows)
                    self.outputsTableView.reloadData(forRowIndexes: rows, columnIndexes: [0])
                }
            }
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification){
        let tableView:NSTableView? = notification.object as? NSTableView
        if(tableView == mixTableView){
            if (appDelegate.isMidiMapping && mixTableView.selectedRow > -1){
                let gainMeter = getAvailableGains()[mixTableView.selectedRow]
                appDelegate.selectedMidiMapId = gainMeter.gain.id
                print("selectedMidiMapId", gainMeter.gain.id)
            }
        }else {
            if (outputsTableView.selectedRow > -1){
                appDelegate.selectedHardwareOutput = getStereoHardwareOutputs()[outputsTableView.selectedRow]
                mixLabel.stringValue = "Mix (" + (appDelegate.selectedHardwareOutput?.nickname.value)! + ")"
                
                mixTableView.reloadData()
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        var count = 0
        if(tableView == mixTableView){
            count = getAvailableGains().count
        }else{
            count = getStereoHardwareOutputs().count
        }
        return count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if(tableView == mixTableView){
            let combinedInput = getAvailableGains()[row]
            combinedInput.setRow(row: row)
            
            return combinedInput
        }else {
            // select default output
            if (outputsTableView.numberOfRows > 0 && outputsTableView.selectedRow < 0){
                outputsTableView.selectRowIndexes([0], byExtendingSelection: false)
            }
            
            let hardwareOutputs = getStereoHardwareOutputs()
            var hardwareOutput: HardwareOutput?
                
            if (hardwareOutputs.count > row){
                hardwareOutput = hardwareOutputs[row]
                hardwareOutput?.row = row
            }
            
            return hardwareOutput
        }
    }
    
//    tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
//
//    let index = NSIndexSet(index: 100)
//    self.tblProjectNumber.scrollRowToVisible(100)
//    self.tblProjectNumber.selectRowIndexes(index, byExtendingSelection: true)
    
}

