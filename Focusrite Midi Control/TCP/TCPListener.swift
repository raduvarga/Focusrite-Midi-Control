//
//  TcpClient.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 07.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//

import Cocoa
import SwiftSocket
import SWXMLHash

class TCPListener: TCPClient{
    
    let ENABLE_LOGGING = false
    
    let RECONNECT_TIME:UInt32 = 3
    let KEEP_ALIVE_TIME:UInt32 = 3
    let SLEEP_TIME:UInt32 = 10000
    
    // You can put whatever hostname and client-key you prefer.
    // But keep the same client-key, becasue if you change that, you will have to
    // re-approve the device
    let clientMsg:String = "<client-details hostname=\"Focusrite Midi Control\" client-key=\"123456789\"/>"
    let keepAliveMsg:String = "<keep-alive/>"
    
    let lengthSize = 14;
    var connected:Bool = false
    var approved:Bool?
    
    var readingWorkItem: DispatchWorkItem? = nil
//    var readingQueue = DispatchQueue(label: "Reading Queue")
    var keepAliveItem: DispatchWorkItem? = nil
//    var keepAliveQueue = DispatchQueue(label: "Keep Alive Queue")
    
    func start(){
        switch connect(timeout: 3) {
            case .success:
                print("---------------")
                print("Connected to TCP")
                setConnected(connected: true)
                sendMessage(msg: clientMsg);
                pollForResponse()
                startKeepAlive()
            case .failure(let error):
                print("connect error:" + error.localizedDescription)
                setConnected(connected: false)
                sleep(RECONNECT_TIME)
                restart()
        }
    }
    
    func setConnected (connected:Bool){
        self.connected = connected
        appDelegate.onConnectionChange(connected: connected)
    }
    
    func setApproved (approved:Bool){
        self.approved = approved
        appDelegate.onApproveChanged(approved: approved)
    }
    
    func restart(){
        print("-----------------------")
        print("Hang on, reconnecting...")
        close()
        start()
    }
    
    func logC(val: Double, forBase base: Double) -> Double {
        return Darwin.log(val)/Darwin.log(base)
    }
    
    func sendVolMessage(item: Item, volume: Int){
        var volume:Double = Double(volume)/100
        // 127 = 6db
        // 108 = 0db
        // range: -70db <--> +6db
        let volumeLimit:String = UserDefaults.standard.string(forKey: "volumeLimit")!
        if (volumeLimit == "0"){
            volume = 1.08/1.27 * volume
        }
        
        // Ableton roughly uses the following formulas for their volumes:
        // - in the upper 50% it's a linear function
        // - in the lower 50%, I've found an exponential aproximation,
        // I'm not sure of the their original function
        var abletonVolume:Double
        if(volume == 0){
            // -128 for mute
            abletonVolume = -128;
        } else if(volume >= 0.48){
            // 1. first (linear) formula
            abletonVolume = 31.45 * volume - 33.95
        } else{
            // 2. second (exponential-log) formula
            abletonVolume =  -0.721 - 67.54 * pow(2, -3.97 * volume)
        }
        
        let newVolMsg:String = "<set devid=\"" + (item.parentDevice?.id)! + "\">" +
                               "<item id=\"" + (item.id) +
                               "\" value=\"" + String(format: "%.1f", abletonVolume)  + "\"/></set>"
        sendMessage(msg: newVolMsg)
    }
    
    func sendSubscribeMessage(deviceId: String){
        let subscribeMsg = "<device-subscribe devid=\"" + deviceId + "\" subscribe=\"true\"/>"

        sendMessage(msg: subscribeMsg)
    }
    
    func handleMessage(msg:String){
        let xmlIndexer:XMLIndexer = SWXMLHash.parse(msg)
        
        if (xmlIndexer["client-details"].element != nil){
            appDelegate.clientId = (xmlIndexer["client-details"].element?.attribute(by: "id")?.text)!
        } else if (xmlIndexer["device-arrival"].element != nil){
            if(ENABLE_LOGGING){
                prettyPrintXML(xml: "Received:" + msg)
            }
            guard let device = appDelegate.onDeviceArrival(xml: xmlIndexer["device-arrival"]["device"]) else {return}
            // subscribe to device. this makes our app appear in the Remote Devices section
            sendSubscribeMessage(deviceId: device.id)
//
        } else if (xmlIndexer["device-removal"].element != nil){
            if(ENABLE_LOGGING){
                prettyPrintXML(xml: "Received:" + msg)
            }
            appDelegate.onDeviceRemoval(xml: xmlIndexer)
            
        } else if (xmlIndexer["approval"].element != nil){
            if(ENABLE_LOGGING){
                prettyPrintXML(xml: "Received:" + msg)
            }
            let id = (xmlIndexer["approval"].element?.attribute(by: "id")?.text)!
            if (appDelegate.clientId == id){
                let newApprovedStr:String = (xmlIndexer["approval"].element?.attribute(by: "authorised")?.text)!
                let newApproved:Bool = (newApprovedStr == "true")
                if (approved == nil || approved != newApproved){
                    setApproved(approved: newApproved)
                }
            }
            
        } else if (xmlIndexer["set"].element != nil){
            if(ENABLE_LOGGING){
                prettyPrintXML(xml: "Received:" + msg)
            }
            appDelegate.onDeviceValues(valuesXML: xmlIndexer["set"])
        } else if (xmlIndexer["keep-alive"].element != nil){
        } else{
            if(ENABLE_LOGGING){
                prettyPrintXML(xml: "Received:" + msg)
            }
        }
    }
    
    // well, sort of
    func prettyPrintXML(xml:String){
        print("--------------------------------------")
        print("Received:" + xml.replacingOccurrences(of: ">", with: ">\n"))
    }
    
    func startKeepAlive() {
        self.keepAliveItem = DispatchWorkItem {
            if(self.connected){
                self.sendMessage(msg: self.keepAliveMsg)
            }
            sleep(self.KEEP_ALIVE_TIME)
            DispatchQueue.global().async(execute: self.keepAliveItem!)
        }
        
        DispatchQueue.global().async(execute: keepAliveItem!)
    }
    
    func pollForResponse(){
        self.readingWorkItem = DispatchWorkItem {
            if(self.connected){
                var lengthMsg:String = self.readMessage(size: self.lengthSize);
                
                if (lengthMsg == ""){
                    sleep(self.SLEEP_TIME)
                }else{
                    let lengthSub = lengthMsg.split(separator: "=")
                    if (lengthSub[0] == "Length"){
                        let hexValue = lengthSub[1].dropLast()
                        if let decimalValue = Int(hexValue, radix: 16) {
                            let dataMsg:String = self.readMessage(size: decimalValue);
                            self.handleMessage(msg: dataMsg)
                        }
                    }
                }
                DispatchQueue.global().async(execute: self.readingWorkItem!)
            }
        }
        
        DispatchQueue.global().async(execute: self.readingWorkItem!)
    }
    
    
    func readMessage(size: Int) -> String{
        guard let data = self.read(size, timeout: 100) else { return "" }
        
        if let response = String(bytes: data, encoding: .utf8) {
            return response
        }
        return "";
    }
    
    func sendMessage(msg:String){
        let tcpMessage = String(format:"Length=%06X %@", msg.count, msg);
        switch self.send(string: tcpMessage) {
        case .success:
            if(ENABLE_LOGGING){
                print("Send:" + msg)
            }
        case .failure(let error):
            print("failed to send message." + error.localizedDescription)
            setConnected(connected: false)
            self.restart()
        }
    }
}
