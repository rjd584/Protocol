//
//  SettingsView.swift
//  Protocol
//
//  Created by Rob Del Gatto on 11/6/22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            ProfileSettingsView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle").environmentObject(SettingsStore())
                }
            
            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintpalette")
                }
            
            PrivacySettingsView()
                .tabItem {
                    Label("Privacy", systemImage: "hand.raised")
                }
        }
        .frame(width: 450, height: 250)
    }
}

struct ProfileSettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        Toggle(isOn: $settings.isNotificationEnabled) {
            Text("Enable Notifications")
        }.toggleStyle(CheckboxToggleStyle())
        Toggle(isOn: $settings.consoleStampsEnabled) {
            Text("Enable Console Stamps")
        }.toggleStyle(CheckboxToggleStyle())
    }
}
 
 
struct AppearanceSettingsView: View {
    var body: some View {
        Text("Appearance Settings")
            .font(.title)
    }
}
 
 
struct PrivacySettingsView: View {
    var body: some View {
        Text("Privacy Settings")
            .font(.title)
    }
}

