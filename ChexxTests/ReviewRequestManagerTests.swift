import XCTest
@testable import Chexx
#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// Verifies the CPU-win review-prompt path added in ReviewRequestManager: it should stay silent
// on the player's 1st CPU win and become eligible to prompt on exactly the 2nd, regardless of
// difficulty. "Eligible to prompt" is asserted indirectly via reviewPromptLastRequestDate, since
// requestReview(in:) only stamps that key once it has decided to actually present the review
// sheet — which requires a real, non-nil presentation context, so the 2nd-win test pulls one
// from the running test host app rather than passing nil like the other two cases.
final class ReviewRequestManagerTests: XCTestCase {
    private let cpuWinCountKey = "reviewPromptCPUWinCount"
    private let lastRequestDateKey = "reviewPromptLastRequestDate"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: cpuWinCountKey)
        UserDefaults.standard.removeObject(forKey: lastRequestDateKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: cpuWinCountKey)
        UserDefaults.standard.removeObject(forKey: lastRequestDateKey)
        super.tearDown()
    }

    private var hostAppPresentationContext: ReviewRequestManager.ReviewPresentationContext? {
        #if canImport(UIKit)
        return UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        #elseif os(macOS)
        return NSApplication.shared.windows.first?.contentViewController
        #endif
    }

    func testFirstCPUWinDoesNotBecomeEligibleToPrompt() {
        ReviewRequestManager.shared.requestReviewAfterCPUWinIfAppropriate(in: hostAppPresentationContext)

        XCTAssertEqual(UserDefaults.standard.integer(forKey: cpuWinCountKey), 1)
        XCTAssertNil(UserDefaults.standard.object(forKey: lastRequestDateKey))
    }

    func testSecondCPUWinBecomesEligibleToPrompt() {
        ReviewRequestManager.shared.requestReviewAfterCPUWinIfAppropriate(in: hostAppPresentationContext)
        ReviewRequestManager.shared.requestReviewAfterCPUWinIfAppropriate(in: hostAppPresentationContext)

        XCTAssertEqual(UserDefaults.standard.integer(forKey: cpuWinCountKey), 2)
        XCTAssertNotNil(UserDefaults.standard.object(forKey: lastRequestDateKey))
    }

    func testThirdCPUWinDoesNotPromptAgain() {
        ReviewRequestManager.shared.requestReviewAfterCPUWinIfAppropriate(in: hostAppPresentationContext)
        ReviewRequestManager.shared.requestReviewAfterCPUWinIfAppropriate(in: hostAppPresentationContext)
        UserDefaults.standard.removeObject(forKey: lastRequestDateKey)

        ReviewRequestManager.shared.requestReviewAfterCPUWinIfAppropriate(in: hostAppPresentationContext)

        XCTAssertEqual(UserDefaults.standard.integer(forKey: cpuWinCountKey), 3)
        // 3rd win doesn't match the exact-2nd-win threshold, so no new prompt is scheduled and
        // the (freshly-cleared) last-request date is left untouched.
        XCTAssertNil(UserDefaults.standard.object(forKey: lastRequestDateKey))
    }
}
