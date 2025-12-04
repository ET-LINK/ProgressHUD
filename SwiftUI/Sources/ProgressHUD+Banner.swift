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

// MARK: - ProgressBannerView
public struct ProgressBannerView: View {

	// MARK: - Properties
	@State private var hud = ProgressHUD.shared

	// MARK: - Initialization
	public init() {}

	// MARK: - Body
	public var body: some View {
		if hud.bannerVisible {
			ZStack {
				// 背景遮罩层（用于控制UI交互）
				Color.black.opacity(0.001)
					.ignoresSafeArea()
					.allowsHitTesting(!hud.bannerInteraction)

				// Banner 内容
				VStack {
					bannerContent
						.padding(.horizontal, 16)
						.padding(.top, 8)
					Spacer()
				}
			}
			.transition(
				.offset(y: -20)
				.combined(with: .opacity)
			)
		}
	}

	// MARK: - Private Views
	private var bannerContent: some View {
		HStack(spacing: 8) {
			// 图标
			if let bannerType = hud.bannerType {
				bannerIcon(for: bannerType)
					.font(.system(size: 20))
					.foregroundStyle(hud.colorBannerTitle)
					.frame(width: 24, height: 24)
			} else if let customIcon = hud.bannerIcon {
				customIcon
					.font(.system(size: 20))
					.foregroundStyle(hud.colorBannerTitle)
					.frame(width: 24, height: 24)
			}

			// 文本内容
			VStack(alignment: .leading, spacing: 4) {
				if let title = hud.bannerTitle, !title.isEmpty {
					Text(title)
						.font(hud.fontBannerTitle)
						.foregroundStyle(hud.colorBannerTitle)
						.lineLimit(1)
				}
				if let message = hud.bannerMessage, !message.isEmpty {
					Text(message)
						.font(hud.fontBannerMessage)
						.foregroundStyle(hud.colorBannerMessage)
						.lineLimit(4)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)

			// 关闭按钮
			if hud.bannerDismissible {
				Button {
					ProgressHUD.bannerHide()
				} label: {
					Image(systemName: "xmark")
						.font(.system(size: 14, weight: .semibold))
						.foregroundStyle(hud.colorBannerTitle.opacity(0.6))
						.frame(width: 24, height: 24)
				}
			}
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 12)
        .contentShape(Rectangle())
        .glassBackground(RoundedRectangle(cornerRadius: 32))
		.onTapGesture {
			if hud.bannerDismissible {
				ProgressHUD.bannerHide()
			}
		}
	}

	@ViewBuilder
	private func bannerIcon(for type: BannerType) -> some View {
		switch type {
		case .loading:
			ProgressView()
				.progressViewStyle(.circular)
                .scaleEffect(1)
		case .success:
			Image(systemName: "checkmark.circle")
		case .error:
			Image(systemName: "xmark.circle")
		case .warning:
			Image(systemName: "exclamationmark.bubble")
		case .info:
			Image(systemName: "info.circle")
		}
	}
}

// MARK: - ProgressBannerModifier
public struct ProgressBannerModifier: ViewModifier {

	// MARK: - Body
	public func body(content: Content) -> some View {
		content.overlay(alignment: .top) {
			ProgressBannerView()
		}
	}
}

// MARK: - View Extension
public extension View {

	func progressBanner() -> some View {
		modifier(ProgressBannerModifier())
	}
}
