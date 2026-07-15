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
        // Bypass URLCache: a transient failure (e.g. no network yet at cold
        // launch) can otherwise get cached as the "response" for this URL,
        // permanently blanking the image on every future load.
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let downloaded = UIImage(data: data) else {
                print("CachedAsyncImage: failed to decode image from \(url)")
                return
            }
            ImageCache.shared.insert(downloaded, for: url)
            uiImage = downloaded
        } catch {
            print("CachedAsyncImage: failed to load \(url): \(error.localizedDescription)")
        }
    }
}
