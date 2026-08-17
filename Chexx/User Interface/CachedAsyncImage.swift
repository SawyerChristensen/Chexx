import SwiftUI
import CryptoKit

/// Backs profile/opponent pictures with both an in-memory cache (for the
/// current app session) and an on-disk cache (so a fresh launch doesn't need
/// to re-download the same picture over the network before showing it — the
/// image loads instantly from disk instead of popping in after a network
/// round trip, and only a URL change causes a fresh download).
final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, PlatformImage>()
    private let diskCacheDirectory: URL?

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        diskCacheDirectory = caches?.appendingPathComponent("ImageCache", isDirectory: true)
        if let diskCacheDirectory {
            try? FileManager.default.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
        }
    }

    func image(for url: URL) -> PlatformImage? {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }
        guard let diskURL = diskCacheURL(for: url),
              let data = try? Data(contentsOf: diskURL),
              let image = PlatformImage(data: data) else {
            return nil
        }
        cache.setObject(image, forKey: url as NSURL)
        return image
    }

    func insert(_ image: PlatformImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
        guard let diskURL = diskCacheURL(for: url),
              let data = image.platformJPEGData(compressionQuality: 0.9) else { return }
        try? data.write(to: diskURL)
    }

    // Swift's String.hashValue is randomized per process, so it can't be used
    // as a stable on-disk filename across launches — hash the URL ourselves.
    private func diskCacheURL(for url: URL) -> URL? {
        guard let diskCacheDirectory else { return nil }
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        let filename = digest.map { String(format: "%02x", $0) }.joined()
        return diskCacheDirectory.appendingPathComponent(filename)
    }
}

/// Drop-in AsyncImage replacement that keeps downloaded images in a shared
/// in-memory cache, so profile/opponent pictures don't re-download every time
/// their view reappears.
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder var content: (Image) -> Content
    @ViewBuilder var placeholder: () -> Placeholder

    @State private var uiImage: PlatformImage?

    var body: some View {
        Group {
            if let uiImage {
                content(Image(platformImage: uiImage))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url else {
            uiImage = nil
            return
        }
        if let cached = ImageCache.shared.image(for: url) {
            uiImage = cached
            return
        }
        // A transient failure (bad network at the moment this view appeared)
        // shouldn't blank the image for good, since the URL is often stable
        // across app sessions (e.g. Google's avatar URL is the same every
        // sign-in) and nothing else would ever trigger another attempt.
        // Retry a couple of times with a short backoff before giving up.
        for attempt in 0..<3 {
            if attempt > 0 {
                try? await Task.sleep(nanoseconds: 500_000_000 * UInt64(attempt))
            }
            // Bypass URLCache: a transient failure can otherwise get cached
            // as the "response" for this URL, permanently blanking the
            // image on every future load.
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                      let downloaded = PlatformImage(data: data) else {
                    print("CachedAsyncImage: failed to decode image from \(url) (attempt \(attempt + 1))")
                    continue
                }
                ImageCache.shared.insert(downloaded, for: url)
                uiImage = downloaded
                return
            } catch {
                print("CachedAsyncImage: failed to load \(url) (attempt \(attempt + 1)): \(error.localizedDescription)")
            }
        }
    }
}
