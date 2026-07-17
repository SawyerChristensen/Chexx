import SwiftUI

final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func insert(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}

/// Drop-in AsyncImage replacement that keeps downloaded images in a shared
/// in-memory cache, so profile/opponent pictures don't re-download every time
/// their view reappears.
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder var content: (Image) -> Content
    @ViewBuilder var placeholder: () -> Placeholder

    @State private var uiImage: UIImage?

    var body: some View {
        Group {
            if let uiImage {
                content(Image(uiImage: uiImage))
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
                      let downloaded = UIImage(data: data) else {
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
