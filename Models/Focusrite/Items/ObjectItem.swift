//
//  IdValuePair.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 09.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//
// An Item that holds a reference to an Object

import Cocoa
import SWXMLHash

class ObjectItem<T: Item>: Item {
    var object: T?
    
    override init(){
        super.init()
    }
    
    override init(xml: XMLIndexer, parentDevice: Device){
        super.init(xml: xml, parentDevice: parentDevice)
    }
    
    override func setValue(value: String) {
        //value here is another id
        self.object = parentDevice?.items[value] as? T
    }
}
