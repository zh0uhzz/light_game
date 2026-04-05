import Foundation

/// 独立小入口：用与 App 相同的 Core 源码在 macOS 上编译运行，按 10 关一批跑完 1…999，
/// 对每关再调用 MinimumBulbSolver 确认有解（生成器内已校验，此为双重确认）。
@main
enum VerifyInfiniteMain {
    static func main() {
        var failed: [String] = []
        // 全表曾校验至 999；生成器现已支持更大序号，此处仍以 10 关一批扫样作为回归。
        for start in stride(from: 1, through: 999, by: 10) {
            let end = start + 9
            let chunk = InfiniteLevelGenerator.levels(inGlobalRange: start...end)
            if chunk.count != end - start + 1 {
                failed.append("chunk count start=\(start) end=\(end)")
                continue
            }
            for lv in chunk {
                if MinimumBulbSolver.findMinimumBulbs(level: lv, maxK: lv.maxBulbs).map({ $0 >= 1 }) != true {
                    failed.append(lv.id)
                }
            }
            fputs("OK \(start)...\(end)\n", stderr)
        }
        if failed.isEmpty {
            print("verify_infinite: all 1...999 OK (batch size 10, solver double-check)")
        } else {
            print("verify_infinite FAILED: \(failed.prefix(20).joined(separator: ", "))")
            exit(1)
        }
    }
}
