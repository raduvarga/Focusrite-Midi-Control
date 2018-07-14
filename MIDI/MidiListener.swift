//
//  MidiListener.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 08.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//

import Cocoa
import CoreMIDI

let ENABLE_LOGGING = false

let appDelegate:AppDelegate  = NSApplication.shared.delegate as! AppDelegate
let CC:Int = 176
let CCMax:Int = 176 + 11
let Note:Int = 144
let NoteMax:Int = 144 + 11

var client:MIDIClientRef = MIDIClientRef()
var inPort:MIDIPortRef = MIDIPortRef()

// read incoming MIDI
func MyMIDIReadProc(pktList: UnsafePointer<MIDIPacketList>,
                    readProcRefCon: UnsafeMutableRawPointer?, srcConnRefCon: UnsafeMutableRawPointer?) -> Void
{
    let packetList:MIDIPacketList = pktList.pointee
    let packet:MIDIPacket = packetList.packet
    
    let first:Int = Int(packet.data.0)
    let second:Int = Int(packet.data.1)
    let third:Int = Int(packet.data.2)
    
    if(ENABLE_LOGGING){
        print("midi:", first,  second, third)
    }
    
    let midiMessage = MidiMessage(type: first, nr: second, value: third)
    
    if midiMessage.isCcMessage() {
        appDelegate.onMidiMessageReceived(midiMessage: midiMessage)
    }
}

// detect when MIDI instruments connect/disconnect
func MyMIDINotifyProc(message: UnsafePointer<MIDINotification>, refCon: UnsafeMutableRawPointer?){
    let notification: MIDINotification = message.pointee
    let notificationID:MIDINotificationMessageID = notification.messageID
    
    switch notificationID {
        case MIDINotificationMessageID.msgObjectAdded:
            print("Midi instrument added")
            connectMidiSources()
        case MIDINotificationMessageID.msgObjectRemoved:
            print("Midi instrument removed")
        default: break
        }
}

// connect MIDI sources to our virtual input port
func connectMidiSources (){
    let sourceCount = MIDIGetNumberOfSources()
    for count in 0...sourceCount {
        var src:MIDIEndpointRef = MIDIGetSource(count)
        MIDIPortConnectSource (inPort, src, &src)
    }
}

class MidiListener: NSObject {
    
    override init() {
        super.init()
    }
   
    func start() {
        MIDIClientCreate("Core MIDI Callback Demo" as CFString, MyMIDINotifyProc, nil, &client)
        MIDIInputPortCreate(client, "Input port" as CFString, MyMIDIReadProc, nil, &inPort)
        
        connectMidiSources();
        
        print ("Connected to MIDI")
    }
}
