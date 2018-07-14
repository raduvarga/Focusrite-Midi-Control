//
//  IdValuePair.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 09.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//
// An Item that holds a reference to a value

import Cocoa
import SWXMLHash

@objc (ValueItem)
class ValueItem: Item {
    @objc var value: String = ""
    
    override func setValue(value: String) {
        self.value = value
    }
}
