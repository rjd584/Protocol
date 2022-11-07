//
//  ContentView.swift
//  Protocol
//
//  Created by Rob Del Gatto on 11/3/22.
//

import SwiftUI
import IOBluetooth
import Combine

struct Message : Equatable  {
    var id: String
    var message: String
    var timestamp: Date
    var sender: String
    
    static func newMessage(message: String) -> Message{
        return Message(id: UUID().uuidString, message: message, timestamp: Date.now, sender: NSUserName())
    }
    
    func getMessage(stamped: Bool) -> String {
        if(stamped){
            return String(sender + " : " + timestamp.formatted() + " : " + message)
        } else {
            return String(message)
        }
    }
    
    func getSender() -> String{
        return sender
    }
    
    func getMessage() -> String {
        return message
    }
    
    func getTimeStamp() -> String {
        return timestamp.formatted()
    }
}


struct ContentView: View {
    @EnvironmentObject var settings: SettingsStore

    @State private var wrapMessage: Bool = true
    @State private var sendhex: Bool = true
    @State private var receiveHex: Bool = false
    @State private var messageText: String = ""
    @State private var firstByte: String = "01"
    @State private var lastByte: String = "04"
    @State private var showStamp: Bool = true
    
    @StateObject var lines = Console.instance
    //@State var filter: Int = 1
    //@State var devices: [BluetoothDevice]
    @State var terminal: SwiftTermViewWrapper = SwiftTermViewWrapper()
    
    
    
    var body: some View {
        VStack {
            terminal
            //ConsoleView()
            HStack {
                TextField("", text: $messageText)
                    .onSubmit {
                        terminal.writeString(string: messageText)
                    }
                    .onReceive(Just(messageText)) { newValue in
                        if(sendhex){
                            let filtered = newValue.filter { "0123456789ABCDEFabcdef".contains($0) }
                            if filtered != newValue {
                                self.messageText = filtered
                            }
                        }
                    }
                Button("Send") {
                    terminal.writeBytes(bytes: [0x30,0x31,0x32,0x33,0x34])
                    //sendMessage()
                }
            }
            HStack {
                TextField("First Byte", text: $firstByte).disabled(sendhex == false)
                TextField("Last Byte", text: $lastByte).disabled(sendhex == false)
                Toggle(isOn: $wrapMessage) {
                    Text("Wrap Message")
                }.toggleStyle(CheckboxToggleStyle()).disabled(sendhex == false)
                Toggle(isOn: $sendhex) {
                    Text("Send Hex")
                }.toggleStyle(CheckboxToggleStyle())
                Toggle(isOn: $receiveHex) {
                    Text("Receive Hex")
                }.toggleStyle(CheckboxToggleStyle())
                Toggle(isOn: $showStamp) {
                    Text("Show Stamp")
                }.toggleStyle(CheckboxToggleStyle()).onChange(of: showStamp){ value in
                    settings.consoleStampsEnabled = value
                }
            }
        }
        .frame(minWidth: 700, minHeight: 300)
        .padding(10)
        .onAppear(){
            terminal.writeString(string: "Welcome to Protocol")
        }
    }
    
    func sendMessage(){
        if(even(number: messageText.count)){
            if(messageText != ""){
                if(receiveHex){
                    BluetoothConnection.instance.printBytes = true
                } else {
                    BluetoothConnection.instance.printBytes = false
                }
                var messageToSend: [UInt8] = []
                if(sendhex){
                    if(wrapMessage){
                        messageToSend += firstByte.hexaBytes
                        messageToSend += messageText.hexaBytes
                        messageToSend += lastByte.hexaBytes
                    } else {
                        messageToSend += messageText.hexaBytes
                    }
                } else {
                    if(wrapMessage){
                        messageToSend += firstByte.hexaBytes
                        messageToSend += Array(messageText.utf8)
                        messageToSend += lastByte.hexaBytes
                    } else {
                        messageToSend += Array(messageText.utf8)
                    }
                }
                BluetoothConnection.instance.sendBytes(message: messageToSend)
                Console.instance.newMessage(message: hexToHexString(data: messageToSend))
            }
        } else {
            Console.instance.newMessage(message: "Hex too short. Must be even.")
        }
    }
    
    func validate() -> Binding<String> {
        let acceptableNumbers: String = "0123456789ABCDEFabcdef"
        return Binding<String>(
            get: {
                return self.messageText
            }) {
                if CharacterSet(charactersIn: acceptableNumbers).isSuperset(of: CharacterSet(charactersIn: $0)) {
                    print("Valid String")
                    self.messageText = $0
                } else {
                    print("Invalid String")
                    self.messageText = $0
                    self.messageText = ""
                }
            }
    }
}





class Console : ObservableObject{
    static let instance = Console();
    @Published var lines: [Message] = []
    
    @discardableResult
    func newMessage(message: String) -> Message{
        let m = Message(id: UUID().uuidString, message: message, timestamp: Date.now, sender: NSUserName())
        lines.append(m)
        return m
    }
    
    @discardableResult
    func newMessage(message: String, sender: String) -> Message{
        let m = Message(id: UUID().uuidString, message: message, timestamp: Date.now, sender: sender)
        lines.append(m)
        return m
    }
}

func hexToHexString(data: [UInt8]) -> String {
    let hexes = data.map { String(format: "%02X", $0) }
    return hexes.joined(separator: ":")
}

func even(number: Int) -> Bool {
    // Return true if number is evenly divisible by 2.
    return number % 2 == 0
}

extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}





