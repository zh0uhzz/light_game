# 电灯（LightGame）iOS MVP

一个单机逻辑益智游戏原型：在灯泡预算内，用圆形半径照亮所有目标格。

## 技术栈
- Swift
- SwiftUI
- 本地 JSON 关卡 + UserDefaults 存档

## 当前已实现
- 圆形半径照亮规则（格子中心点判定）
- 放置/移除灯泡、撤销、重开
- 通关检测（目标全部点亮 + 灯泡不超预算）
- 章节与关卡列表
- 完成进度存档
- 关卡教程与震动反馈

## 目录
- `App`: 应用入口
- `Core`: 模型、规则、引擎、关卡加载
- `Features`: 棋盘与章节 UI、进度
- `Data`: 手工关卡 JSON
- `Tools`: 关卡数据校验工具

## 接入 Xcode
1. 在 Xcode 创建 iOS App 工程（SwiftUI）。
2. 将 `LightGame` 目录拖入工程并勾选 `Copy items if needed`。
3. 确保 `Data/levels_pack_01.json` 已加入 target 的 `Copy Bundle Resources`。
4. 运行 iPhone 模拟器即可体验。

## 上架准备清单
- 应用名称：电灯
- 隐私：离线单机，无账号，无网络跟踪
- 素材：1024 App Icon、6.7/6.5 英寸截图、玩法视频
- 元数据：中文短描述 + 关键字（逻辑、益智、单机、烧脑）
