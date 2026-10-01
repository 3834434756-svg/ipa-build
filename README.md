# WaterCheckIn · 喝水打卡

每日喝水打卡 iOS App（SwiftUI，iOS 16+）：

- 进度环展示今日饮水量 vs 每日目标
- 小杯 +250 / 大杯 +500 / 撤销 / 自定义
- 最近 7 天柱状图 + 连续达标天数（🔥）
- 目标可切换（1500/2000/2500/3000 ml），数据存本地 UserDefaults

## 云端构建未签名 IPA

推送 `main` 自动触发 [.github/workflows/build-unsigned-ipa.yml](.github/workflows/build-unsigned-ipa.yml)，
在 GitHub 托管的 macOS runner 上 `xcodegen generate` → `xcodebuild archive`（关闭签名）→ 打未签名 IPA，
并自动发到 [Releases](../../releases)（无需登录即可下载）。

> 产物是**未签名** IPA：需要用免费 Apple ID（Sideloadly / AltStore / SideStore）重签后才能安装，
> 免费签名 7 天有效期。
