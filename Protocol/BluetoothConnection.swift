//
//  BluetoothConnection.swift
//  Protocol
//
//  Created by Rob Del Gatto on 11/4/22.
//

import IOBluetooth
import CoreBluetooth
import SwiftUI


class BluetoothConnection : NSObject, IOBluetoothRFCOMMChannelDelegate {
    var ConsoleInstance = Console.instance
    var mRFCOMMChannel : IOBluetoothRFCOMMChannel?;
    static let instance = BluetoothConnection();
    var printBytes: Bool = false
    
    func connect(address: String){
        guard let bluetoothDevice = IOBluetoothDevice(addressString: address) else {
            printMessage(message: "Device Not Found")
            exit(-2)
        }

        if !bluetoothDevice.isPaired() {
            printMessage(message: "Device Not Connected")
        }
        
        printMessage(message: "Opening rfcomm port")
        
        let sppServiceUUID = IOBluetoothSDPUUID.uuid32(kBluetoothSDPUUID16ServiceClassSerialPort.rawValue)
        let sppServiceRecord = bluetoothDevice.getServiceRecord(for: sppServiceUUID)
        var rfCommChannelID: BluetoothRFCOMMChannelID = 0;
        
        if (sppServiceRecord?.getRFCOMMChannelID(&rfCommChannelID) != kIOReturnSuccess ) {
            printMessage(message: "Error - no spp service in selected device.  ***This should never happen an spp service must have an rfcomm channel id.***\n")
            return;
        }
        var error : IOReturn = -1
        error = bluetoothDevice.openRFCOMMChannelSync(&mRFCOMMChannel, withChannelID: rfCommChannelID, delegate: self)
        
        if (error > 0) {
            printMessage(message: "Error opening port")
        }
    
    }

    func rfcommChannelOpenComplete(_ rfcommChannel: IOBluetoothRFCOMMChannel!, status error: IOReturn) {
        if(error != kIOReturnSuccess){
            printMessage(message: "Error - Failed to open the RFCOMM channel")
        }
        else {
            printMessage(message: "Connected")
        }
    }
    
    var receivedBuffer: [UInt8] = []
        
    func rfcommChannelData(_ rfcommChannel: IOBluetoothRFCOMMChannel!, data dataPointer: UnsafeMutableRawPointer, length dataLength: Int) {
        let receivedData = UnsafeBufferPointer(start: dataPointer.assumingMemoryBound(to: UInt8.self), count: dataLength)
        receivedBuffer += receivedData

        if(receivedData[dataLength - 1] == 0x04){
            if(printBytes){
                printMessage(message: hexToHexString(data: receivedBuffer), sender: rfcommChannel.getID().formatted())
            } else {
                printMessage(message: String(bytes: receivedBuffer, encoding:  String.Encoding.utf8) ?? "Received Data Error", sender: rfcommChannel.getID().formatted())
            }
            receivedBuffer = []
        }
    }
    
    func printMessage(message: String, sender: String){
        if(!(message == "")){
            ConsoleInstance.newMessage(message: message, sender: sender)
        }
    }
    
    func printMessage(message: String){
        if(!(message == "")){
            ConsoleInstance.newMessage(message: message)
        }
    }
    
    func sendBytes(message: [UInt8]){
        var byteArray: [UInt8] = message
        let length = byteArray.count
        mRFCOMMChannel?.writeSync(&byteArray, length: UInt16(length))
    }
    
    func sendMessage(message: String){
        let data = message.data(using: String.Encoding.utf8)
        let length = data!.count
        let dataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
            
        data?.copyBytes(to: dataPointer,count: length)
        
        if(send(data: dataPointer, length: UInt16(length)) > 0){
            printMessage(message: "Error sending message")
        } else {
            printMessage(message: message)
        }
    }
    
    @discardableResult
    func send(data: UnsafeMutablePointer<UInt8>, length: UInt16) -> IOReturn {
        return mRFCOMMChannel?.writeSync(data, length: UInt16(length)) ?? 1
    }
}





