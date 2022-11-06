//
//  ProtocolApp.swift
//  Protocol
//
//  Created by Rob Del Gatto on 11/3/22.
//

import SwiftUI
import IOBluetooth



@main
struct ProtocolApp: App {
    @State var filter = 1
    @State var devices: [BluetoothDevice] = []
    
    var body: some Scene {
        WindowGroup{
            ContentView(filter: $filter, devices: $devices)
        }.commands {
            CommandMenu("Connection") {
                Button("Refresh List"){
                    getDevices()
                }
                Picker(selection: $filter, label: Text("Filter")) {
                    ForEach(devices) { device in
                        Text(device.name + " : " + device.address).tag(device.id)
                    }
                }
                Button("Connect"){
                    BluetoothConnection.instance.connect(address: devices[filter].address)
                }
            }
        }
        
        Settings {
            SettingsView()
        }
    }
    
    func getDevices(){
        guard let btdevices = IOBluetoothDevice.pairedDevices() else {
              print("No devices")
              return
            }
            var index = 0
            for item in btdevices {
              if let device = item as? IOBluetoothDevice {
                  devices.append(BluetoothDevice(id: index,name: device.name, address: device.addressString))
                  index += 1
              }
            }
    }
}
    
    struct BluetoothDevice : Identifiable{
        var id: Int
        var name: String
        var address: String
        
    }
    
