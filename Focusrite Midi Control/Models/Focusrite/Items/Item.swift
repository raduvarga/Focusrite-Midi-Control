//
//  Item.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 10.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//
// Any tag name from the XML that has an id property is an Item.

import Cocoa
import SWXMLHash

@objc (Item)
class Item: NSObject {
    @objc var parentDevice: Device?
    @objc var id: String = ""
    @objc var row: Int = -1
    
    override init(){
        super.init()
    }
    
    init(xml: XMLIndexer, parentDevice: Device){
        super.init()
        self.parentDevice = parentDevice
//        print("xml", xml.element?.name, xml.description)
        if(xml.element != nil){
            self.id = (xml.element?.value(ofAttribute: "id"))!
        }
        // add this item to the global dictionary of items
        parentDevice.items[id] = self
    }
    
    func setValue(value: String) {
        // no default action
    }
}
