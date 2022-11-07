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
    var body: some Scene {
        WindowGroup{
            ContentView().environmentObject(SettingsStore())
        }.commands {
            ConnectionMenu()
            ConsoleMenu(settings: SettingsStore())
        }
        
        
        Settings {
            SettingsView().environmentObject(SettingsStore())
        }
    }
}

struct ConnectionMenu: Commands {
    var body: some Commands{
        CommandMenu("Connection"){
            NavigationLink(destination: ConnectionView()){
                Text("Show Detail View")
            }
        }
    }
}

struct ConsoleMenu: Commands {
    @ObservedObject var settings: SettingsStore
    
    var body: some Commands{
        CommandMenu("Console"){
            Toggle(isOn: $settings.consoleStampsEnabled) {
                Text("Enable Console Stamps")
            }.toggleStyle(CheckboxToggleStyle())
        }
    }
}

struct BluetoothDevice : Identifiable{
    var id: Int
    var name: String
    var address: String
    
    
    
}

func getDevices() -> [BluetoothDevice]{
    var devices: [BluetoothDevice] = []
    guard let btdevices = IOBluetoothDevice.pairedDevices() else {
        print("No devices")
        return devices
    }
    var index = 0
    for item in btdevices {
        if let device = item as? IOBluetoothDevice {
            devices.append(BluetoothDevice(id: index,name: device.name, address: device.addressString))
            index += 1
        }
    }
    return devices
}

