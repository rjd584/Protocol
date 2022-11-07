//
//  ConnectionView.swift
//  Protocol
//
//  Created by Rob Del Gatto on 11/6/22.
//

import SwiftUI

struct ConnectionView: View {
    @State var filter = 1
    @State var devices: [BluetoothDevice] = []
    
    
    var body: some View {
        Text("Connection View")
//        Button("Refresh List"){
//            //getDevices(devices: devices)
//        }
//        Picker(selection: $filter, label: Text("Filter")) {
//            //            ForEach(devices) { device in
//            //                Text(device.name + " : " + device.address).tag(device.id)
//            //            }
//        }
//        Button("Connect"){
//            BluetoothConnection.instance.connect(address: devices[filter].address)
//        }
        
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView()
    }
}
