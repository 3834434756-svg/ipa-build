import Foundation

/// 数据模型：每日饮水量记录 + 目标，持久化到 UserDefaults
final class WaterStore: ObservableObject {
    static let cupML = 250

    private static let goalKey = "water.goal"
    private static let dailyKey = "water.daily"

    @Published var goal: Int                 // 每日目标（ml）
    private(set) var daily: [String: Int]     // "yyyy-MM-dd" -> ml

    init() {
        let d = UserDefaults.standard
        goal = d.object(forKey: Self.goalKey) as? Int ?? 2000
        daily = d.object(forKey: Self.dailyKey) as? [String: Int] ?? [:]
        prune()
        persist()
    }

    // MARK: - 日期工具

    private func key(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = .current
        return df.string(from: date)
    }

    func todayKey() -> String { key(Date()) }

    /// 只保留最近 31 天
    private func prune() {
        guard let cutoff = Calendar.current.date(byAdding: .day, value: -31,
                                                  to: Calendar.current.startOfDay(for: Date())) else { return }
        let ck = key(cutoff)
        for k in daily.keys where k < ck { daily[k] = nil }
    }

    private func persist() {
        UserDefaults.standard.set(goal, forKey: Self.goalKey)
        UserDefaults.standard.set(daily, forKey: Self.dailyKey)
    }

    // MARK: - 记录

    var todayTotal: Int { daily[todayKey()] ?? 0 }

    func add(ml: Int) {
        let k = todayKey()
        daily[k, default: 0] += ml
        persist()
    }

    func undo(ml: Int) {
        let k = todayKey()
        daily[k] = max(0, (daily[k] ?? 0) - ml)
        persist()
    }

    func setGoal(_ g: Int) {
        goal = g
        persist()
    }

    // MARK: - 统计

    /// 最近 7 天（含今天），按时间正序
    func last7() -> [(date: Date, ml: Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<7).reversed().compactMap { off in
            guard let d = cal.date(byAdding: .day, value: -off, to: today) else { return nil }
            return (d, daily[key(d)] ?? 0)
        }
    }

    /// 连续达标天数（今天未达标不算断）
    var streak: Int {
        let cal = Calendar.current
        var n = 0
        var d = cal.startOfDay(for: Date())
        if (daily[key(d)] ?? 0) >= goal { n += 1 }
        while let prev = cal.date(byAdding: .day, value: -1, to: d) {
            if (daily[key(prev)] ?? 0) >= goal {
                n += 1
                d = prev
            } else {
                break
            }
        }
        return n
    }
}
