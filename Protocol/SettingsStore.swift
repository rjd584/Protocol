//
//  SettingsStore.swift
//  Protocol
//
//  Created by Rob Del Gatto on 11/6/22.
//
import SwiftUI
import Combine

final class SettingsStore: ObservableObject {
    private enum Keys {
        static let consoleStampsEnabled = "console_stamps_enabled"
        static let notificationEnabled = "notifications_enabled"
    }

    private let cancellable: Cancellable
    private let defaults: UserDefaults

    let objectWillChange = PassthroughSubject<Void, Never>()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        defaults.register(defaults: [
            Keys.consoleStampsEnabled: true,
            Keys.notificationEnabled: false,
            ])

        cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .subscribe(objectWillChange)
    }

    var isNotificationEnabled: Bool {
        set { defaults.set(newValue, forKey: Keys.notificationEnabled) }
        get { defaults.bool(forKey: Keys.notificationEnabled) }
    }

    var consoleStampsEnabled: Bool {
        set { defaults.set(newValue, forKey: Keys.consoleStampsEnabled) }
        get { defaults.bool(forKey: Keys.consoleStampsEnabled) }
    }

}

extension SettingsStore {
    func unlockPro() {
        // You can do your in-app transactions here
        consoleStampsEnabled = true
    }

    func restorePurchase() {
        // You can do you in-app purchase restore here
        consoleStampsEnabled = true
    }
}
