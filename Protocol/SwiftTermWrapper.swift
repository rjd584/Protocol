//
//  SwiftTermWrapper.swift
//  Protocol
//
//  Created by Rob Del Gatto on 11/7/22.
//

import Foundation
import AppKit
import SwiftUI
import SwiftTerm

struct SwiftTermViewWrapper: NSViewRepresentable {
    let lptView = LocalProcessTerminalView(frame: CGRect())

    func makeNSView(context: Context) ->  LocalProcessTerminalView {
        return lptView
    }
    
    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
        
    }
    
    func writeString(string: String){
        lptView.feed(text: string + "\r\n")
    }
    
    func writeBytes(bytes: [UInt8]){
        var temp = bytes
        temp += [0x0A, 0x0D]
        lptView.feed(byteArray: ArraySlice(temp))
    }
}
