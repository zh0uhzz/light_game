import Foundation

enum LevelLoaderError: Error {
    case fileNotFound
    case decodeFailed
}

struct LevelLoader {
    func load(from url: URL) throws -> LevelPack {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw LevelLoaderError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        do {
            return try JSONDecoder().decode(LevelPack.self, from: data)
        } catch {
            throw LevelLoaderError.decodeFailed
        }
    }
}
