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

import SwiftUI

// MARK: - GlassBackgroundModifier
public struct GlassBackgroundModifier: ViewModifier {

	// MARK: - Properties
	let shape: AnyShape

	// MARK: - Initialization
	public init<S: Shape>(shape: S) {
		self.shape = AnyShape(shape)
	}

	// MARK: - Body
	public func body(content: Content) -> some View {
		 if #available(iOS 26.0, *) {
		 	content
                .glassEffect(.regular.tint(.white.opacity(0.1)), in: shape)
		 } else {
			content
				.background {
					shape
						.fill(.ultraThinMaterial)
                        .overlay(shape.stroke(.primary.opacity(0.1), lineWidth: 1))
				}
		 }
	}
}

// MARK: - View Extension
public extension View {

	/// Applies a glass background effect with shape and color customization
	/// - Parameters:
	///   - shape: The shape of the background (default: RoundedRectangle with 10pt corners)
	///   - backgroundColor: The background color (default: .clear)
	/// - Returns: A view with glass background effect
	func glassBackground<S: Shape>(
		_ shape: S = RoundedRectangle(cornerRadius: 10),
		backgroundColor: Color = .clear
	) -> some View {
		modifier(GlassBackgroundModifier(shape: shape))
	}
}
