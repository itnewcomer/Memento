import SwiftUI
import UserNotifications

struct SettingsView: View {
    // 日時リマインダー
    @AppStorage("reminderDate") private var reminderDate: Double = Date().timeIntervalSince1970
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false

    // 月次リマインダー
    @AppStorage("monthlyReminderDay") private var monthlyReminderDay: Int = 1
    @AppStorage("monthlyReminderHour") private var monthlyReminderHour: Int = 9
    @AppStorage("monthlyReminderEnabled") private var monthlyReminderEnabled: Bool = false

    var body: some View {
        NavigationView {
            Form {
                // 日時リマインダー
                Section(header: Text("日時リマインダー")) {
                    Toggle("有効にする", isOn: $reminderEnabled)
                        .onChange(of: reminderEnabled) { _, newValue in
                            if newValue {
                                scheduleDailyReminder()
                            } else {
                                removeDailyReminder()
                            }
                        }
                    DatePicker("リマインド時刻", selection: Binding(
                        get: { Date(timeIntervalSince1970: reminderDate) },
                        set: {
                            reminderDate = $0.timeIntervalSince1970
                            if reminderEnabled {
                                scheduleDailyReminder()
                            }
                        }
                    ), displayedComponents: [.hourAndMinute])
                        .disabled(!reminderEnabled)
                }

                // 月次リマインダー
                Section(header: Text("月次リマインダー")) {
                    Toggle("有効にする", isOn: $monthlyReminderEnabled)
                        .onChange(of: monthlyReminderEnabled) { _, newValue in
                            if newValue {
                                scheduleMonthlyReminder()
                            } else {
                                removeMonthlyReminder()
                            }
                        }
                    HStack {
                        Text("日付")
                        Picker("", selection: $monthlyReminderDay) {
                            ForEach(1...28, id: \.self) { day in
                                Text("\(day)日").tag(day)
                            }
                        }
                        .pickerStyle(.menu)
                        .disabled(!monthlyReminderEnabled)
                    }
                    HStack {
                        Text("時刻")
                        Picker("", selection: $monthlyReminderHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d:00", hour)).tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        .disabled(!monthlyReminderEnabled)
                    }
                }

                // 情報
                Section(header: Text("情報")) {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
        }
        .onAppear {
            requestNotificationPermission()
        }
    }

    // MARK: - Notification Helpers

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func scheduleDailyReminder() {
        removeDailyReminder()
        let date = Date(timeIntervalSince1970: reminderDate)
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        var trigger = DateComponents()
        trigger.hour = components.hour
        trigger.minute = components.minute

        let content = UNMutableNotificationContent()
        content.title = "今日の記録をつけましょう"
        content.body = "カレンダーに今日の気分や出来事を記録しましょう。"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func removeDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
    }

    private func scheduleMonthlyReminder() {
        removeMonthlyReminder()
        var trigger = DateComponents()
        trigger.day = monthlyReminderDay
        trigger.hour = monthlyReminderHour
        trigger.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "月次レポートを見てみましょう"
        content.body = "1ヶ月の振り返りをしてみませんか？"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "monthly_reminder",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func removeMonthlyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["monthly_reminder"])
    }
}
