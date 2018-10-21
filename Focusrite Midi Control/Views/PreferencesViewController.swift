//
//  PreferencesController.swift
//  Focusrite Midi Control
//
//  Created by Antonio-Radu Varga on 08.07.18.
//  Copyright © 2018 Antonio-Radu Varga. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    @IBOutlet weak var volumeLimitDropdown: NSPopUpButton!
    @IBOutlet weak var mapAllMixesCheckbox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
        
        volumeLimitDropdown.removeAllItems()
        volumeLimitDropdown.addItems(withTitles: ["0", "6"])
        let volumeLimit:String = UserDefaults.standard.string(forKey: "volumeLimit")!
        volumeLimitDropdown.selectItem(withTitle: volumeLimit)
        
        let midiMapAllMixes:Bool = UserDefaults.standard.bool(forKey: "midiMapAllMixes")
        mapAllMixesCheckbox.state = midiMapAllMixes ? NSControl.StateValue.on : NSControl.StateValue.off
        
        print ("yooo")
    }
    
    @IBAction func onMapAllChange(_ sender: Any) {
        let midiMapAllMixes:Bool = mapAllMixesCheckbox.state == NSControl.StateValue.on
        UserDefaults.standard.set(midiMapAllMixes, forKey: "midiMapAllMixes")
    }
    
    @IBAction func onVolumeLimitDropdownChange(_ sender: Any) {
        let volumeLimit:String = (volumeLimitDropdown.selectedItem?.title)!
        UserDefaults.standard.set(volumeLimit, forKey: "volumeLimit")
    }
    
}
