//
//  MixerInput.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 10.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//

import Cocoa
import SWXMLHash

class MixerInput: NSObject {
    var source: ObjectItem<HardwareInput> = ObjectItem()
    var stereo: ValueItem = ValueItem()
    
    override init(){
        super.init()
    }
    
    init(xml: XMLIndexer, parentDevice: Device){
        super.init()
        source = ObjectItem(xml: xml["source"], parentDevice: parentDevice)
        stereo =  ValueItem(xml: xml["stereo"], parentDevice: parentDevice)
    }
    
    func isStereo() -> Bool {
        return (stereo.value == "true")
    }
}
