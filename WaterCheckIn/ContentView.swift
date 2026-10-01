import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var store: WaterStore
    @State private var showCustom = false
    @State private var customML = 250

    private var progress: Double {
        store.goal > 0 ? min(1, Double(store.todayTotal) / Double(store.goal)) : 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ringCard
                    if store.todayTotal >= store.goal { goalCard }
                    logButtons
                    weekCard
                    settingsCard
                }
                .padding()
                .frame(maxWidth: 500)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("喝水打卡")
            .sheet(isPresented: $showCustom) { customSheet }
        }
    }

    // MARK: - 进度环

    private var ringCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.15), lineWidth: 22)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 22, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.4), value: progress)
                VStack(spacing: 2) {
                    Text("\(store.todayTotal)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                    Text("/ \(store.goal) ml")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 210, height: 210)

            HStack {
                HStack(spacing: 5) {
                    let filled = min(8, store.todayTotal / WaterStore.cupML)
                    ForEach(0..<8, id: \.self) { i in
                        Image(systemName: i < filled ? "drop.fill" : "drop")
                            .font(.title3)
                            .foregroundStyle(i < filled ? Color.blue : Color.secondary.opacity(0.35))
                    }
                }
                Spacer()
                Label("\(store.streak) 天连续", systemImage: "flame.fill")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }

    private var goalCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title)
                .foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text("今天达标了，继续加油！")
                    .font(.headline)
                Text("连续 \(store.streak) 天保持")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }

    // MARK: - 记录按钮

    private var logButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                logButton(title: "小杯", subtitle: "+250 ml", icon: "drop.fill") { store.add(ml: 250) }
                logButton(title: "大杯", subtitle: "+500 ml", icon: "drop.fill") { store.add(ml: 500) }
            }
            HStack(spacing: 12) {
                logButton(title: "撤销", subtitle: "-250 ml", icon: "minus.circle.fill") { store.undo(ml: 250) }
                logButton(title: "自定义", subtitle: "手动填写", icon: "plus.circle.fill") { showCustom = true }
            }
        }
    }

    private func logButton(title: String, subtitle: String, icon: String,
                          action: @escaping () -> Void) -> some View {
        Button {
            action()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.blue.opacity(0.12))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }

    private var customSheet: some View {
        NavigationStack {
            Form {
                Stepper(value: $customML, in: 50...2000, step: 50) {
                    LabeledContent("加水量", value: "\(customML) ml")
                }
            }
            .navigationTitle("自定义加水")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { showCustom = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("加上") {
                        store.add(ml: customML)
                        showCustom = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - 最近 7 天

    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("最近 7 天")
                .font(.headline)
            HStack(alignment: .bottom, spacing: 8) {
                let days = store.last7()
                let maxMl = max(store.goal, days.map(\.ml).max() ?? 1, 1)
                ForEach(days.indices, id: \.self) { i in
                    let d = days[i]
                    VStack(spacing: 4) {
                        BarView(ml: d.ml, goal: store.goal, maxMl: maxMl)
                        Text(shortWeekday(d.date))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(height: 130, alignment: .bottom)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }

    private func shortWeekday(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "今天" }
        let df = DateFormatter()
        df.dateFormat = "EEE"
        df.locale = Locale(identifier: "zh_CN")
        return df.string(from: date)
    }

    // MARK: - 目标设置

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("每日目标")
                .font(.headline)
            HStack(spacing: 8) {
                ForEach([1500, 2000, 2500, 3000], id: \.self) { g in
                    Button("\(g) ml") { store.setGoal(g) }
                        .buttonStyle(.bordered)
                        .tint(store.goal == g ? .blue : .gray)
                        .controlSize(.small)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }
}

/// 单个日条
struct BarView: View {
    let ml: Int
    let goal: Int
    let maxMl: Int

    var body: some View {
        GeometryReader { geo in
            let h = maxMl > 0 ? CGFloat(ml) / CGFloat(maxMl) * geo.size.height : 0
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.blue.opacity(0.12))
                Rectangle()
                    .fill(ml >= goal ? Color.green : Color.blue)
                    .frame(height: max(h, ml > 0 ? 6 : 0))
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
