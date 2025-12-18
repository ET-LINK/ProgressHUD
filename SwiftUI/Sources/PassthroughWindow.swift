//
// Copyright (c) 2025 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

// MARK: - PassthroughWindow
/// A custom UIWindow that can selectively pass touch events through to underlying windows
class PassthroughWindow: UIWindow {

	// MARK: - Properties
	/// When true, only banner content area will receive touches; other areas pass through
	var shouldPassthroughTouches = false

	// MARK: - Hit Testing
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		// Get the default hit test result
		guard let hitView = super.hitTest(point, with: event) else {
			return nil
		}

		// If passthrough is disabled, behave normally
		guard shouldPassthroughTouches else {
			return hitView
		}

		// If the hit view is the root view or one of the hosting controller's internal views,
		// it means the touch landed on the background (not on actual banner content)
		// In this case, pass through to allow interaction with underlying UI
		if hitView == rootViewController?.view {
			return nil
		}

		// Check if hit view is a system hosting view (SwiftUI internals)
		let className = String(describing: type(of: hitView))
		if className.contains("UIHosting") || className.contains("ViewHost") {
			return nil
		}

		// Otherwise, return the hit view (banner content or its subviews)
		return hitView
	}
}
