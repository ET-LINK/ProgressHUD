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

// MARK: - Show Banner
extension ProgressHUD {

	func showBanner(title: String?, message: String?, delay: TimeInterval) {
		setupWindow()
		removeBanner()

		textBannerTitle = title ?? ""
		textBannerMessage = message ?? ""
		bannerType = nil
		bannerIcon = nil
		bannerDismissible = true
		bannerInteraction = true

		setupBannerView()
		animateBannerIn()
		scheduleBannerDismiss(delay: delay)
		createBannerObserver()
	}

	func showBanner(type: BannerType, title: String?, message: String?, delay: TimeInterval?) {
		setupWindow()
		removeBanner()

		textBannerTitle = title ?? ""
		textBannerMessage = message ?? ""
		bannerType = type
		bannerIcon = nil

		// loading 类型不可关闭且阻塞交互
		if type == .loading {
			bannerDismissible = false
			bannerInteraction = false
		} else {
			bannerDismissible = true
			bannerInteraction = true
		}

		setupBannerView()
		animateBannerIn()

		// 如果指定了 delay 或者不是 loading 类型，自动隐藏
		if let delay = delay, delay > 0 {
			scheduleBannerDismiss(delay: delay)
		} else if type != .loading {
			// 非 loading 类型默认 3 秒后自动隐藏
			scheduleBannerDismiss(delay: 3.0)
		}

		createBannerObserver()
	}

	private func setupBannerView() {
		// 创建主容器（使用 UIVisualEffectView）
		let effectView = createGlassEffectView()
		viewBanner = effectView

		// 创建水平 stack view
		let horizontalStack = UIStackView()
		horizontalStack.axis = .horizontal
		horizontalStack.spacing = 8
		horizontalStack.alignment = .center
		horizontalStack.translatesAutoresizingMaskIntoConstraints = false

		// 添加图标
		if let type = bannerType {
			let iconView = createIconView(for: type)
			bannerIconView = iconView
			horizontalStack.addArrangedSubview(iconView)
		} else if let customIcon = bannerIcon {
			let iconView = createCustomIconView(image: customIcon)
			bannerIconView = iconView
			horizontalStack.addArrangedSubview(iconView)
		}

		// 创建垂直 stack view（包含 title 和 message）
		let verticalStack = UIStackView()
		verticalStack.axis = .vertical
		verticalStack.spacing = 4
		verticalStack.alignment = .leading

		// 添加 title label
		if !textBannerTitle.isEmpty {
			let titleLabel = UILabel()
			titleLabel.text = textBannerTitle
			titleLabel.font = fontBannerTitle
			titleLabel.textColor = colorBannerTitle
			titleLabel.numberOfLines = 1
			labelBannerTitle = titleLabel
			verticalStack.addArrangedSubview(titleLabel)
		}

		// 添加 message label
		if !textBannerMessage.isEmpty {
			let messageLabel = UILabel()
			messageLabel.text = textBannerMessage
			messageLabel.font = fontBannerMessage
			messageLabel.textColor = colorBannerMessage
			messageLabel.numberOfLines = 4
			labelBannerMessage = messageLabel
			verticalStack.addArrangedSubview(messageLabel)
		}

		horizontalStack.addArrangedSubview(verticalStack)

		// 添加关闭按钮
		if bannerDismissible {
			let closeButton = createCloseButton()
			bannerCloseButton = closeButton
			horizontalStack.addArrangedSubview(closeButton)
		}

		// 将 stack view 添加到 effect view 的 contentView
		effectView.contentView.addSubview(horizontalStack)

		// 设置约束
		NSLayoutConstraint.activate([
			horizontalStack.topAnchor.constraint(equalTo: effectView.contentView.topAnchor, constant: 12),
			horizontalStack.bottomAnchor.constraint(equalTo: effectView.contentView.bottomAnchor, constant: -12),
			horizontalStack.leadingAnchor.constraint(equalTo: effectView.contentView.leadingAnchor, constant: 16),
			horizontalStack.trailingAnchor.constraint(equalTo: effectView.contentView.trailingAnchor, constant: -16)
		])

		// 设置 banner 的位置和大小
		let bannerWidth = main.frame.width - 32
		effectView.translatesAutoresizingMaskIntoConstraints = false
		main.addSubview(effectView)

		NSLayoutConstraint.activate([
			effectView.topAnchor.constraint(equalTo: main.safeAreaLayoutGuide.topAnchor, constant: 8),
			effectView.leadingAnchor.constraint(equalTo: main.leadingAnchor, constant: 16),
			effectView.trailingAnchor.constraint(equalTo: main.trailingAnchor, constant: -16)
		])

		// 添加点击手势
		if bannerDismissible {
			let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideBanner))
			effectView.addGestureRecognizer(tapGesture)
		}

		// 如果不允许交互，添加透明遮罩层
		if !bannerInteraction {
			let blockingView = UIView(frame: main.bounds)
			blockingView.backgroundColor = UIColor.black.withAlphaComponent(0.001)
			blockingView.tag = 9999 // 标记用于后续移除
			main.insertSubview(blockingView, belowSubview: effectView)
		}

		// 强制布局以获取实际高度，然后设置圆角
		effectView.layoutIfNeeded()
		let cornerRadius = min(32, effectView.bounds.height / 2)
		effectView.layer.cornerRadius = cornerRadius
	}

	private func createGlassEffectView() -> UIVisualEffectView {
		let effectView: UIVisualEffectView

		if #available(iOS 26.0, *) {
			let glassEffect = UIGlassEffect(style: .regular)
			glassEffect.tintColor = UIColor.white.withAlphaComponent(0.1)
			effectView = UIVisualEffectView(effect: glassEffect)
		} else {
			let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
			effectView = UIVisualEffectView(effect: blurEffect)
		}

		// 圆角会在布局完成后动态设置
		effectView.clipsToBounds = true

		// iOS 26 以下版本添加边框
		if #available(iOS 26.0, *) {
			// iOS 26+ glassEffect 自带边框效果，不需要额外添加
		} else {
			effectView.layer.borderWidth = 1
			effectView.layer.borderColor = UIColor.label.withAlphaComponent(0.1).cgColor
		}

		return effectView
	}

	private func createIconView(for type: BannerType) -> UIView {
		switch type {
		case .loading:
			let indicator = UIActivityIndicatorView(style: .medium)
			indicator.color = colorBannerTitle
			indicator.startAnimating()
			indicator.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				indicator.widthAnchor.constraint(equalToConstant: 24),
				indicator.heightAnchor.constraint(equalToConstant: 24)
			])
			return indicator

		case .success:
			return createIconImageView(systemName: "checkmark.circle")

		case .error:
			return createIconImageView(systemName: "xmark.circle")

		case .warning:
			return createIconImageView(systemName: "exclamationmark.bubble")

		case .info:
			return createIconImageView(systemName: "info.circle")
		}
	}

	private func createIconImageView(systemName: String) -> UIImageView {
		let imageView = UIImageView()
		let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
		imageView.image = UIImage(systemName: systemName, withConfiguration: config)
		imageView.tintColor = colorBannerTitle
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			imageView.widthAnchor.constraint(equalToConstant: 24),
			imageView.heightAnchor.constraint(equalToConstant: 24)
		])

		return imageView
	}

	private func createCustomIconView(image: UIImage) -> UIImageView {
		let imageView = UIImageView(image: image)
		imageView.tintColor = colorBannerTitle
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			imageView.widthAnchor.constraint(equalToConstant: 24),
			imageView.heightAnchor.constraint(equalToConstant: 24)
		])

		return imageView
	}

	private func createCloseButton() -> UIButton {
		let button = UIButton(type: .system)
		let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
		button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
		button.tintColor = colorBannerTitle.withAlphaComponent(0.6)
		button.addTarget(self, action: #selector(hideBanner), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalToConstant: 24),
			button.heightAnchor.constraint(equalToConstant: 24)
		])

		return button
	}

	private func animateBannerIn() {
		guard let banner = viewBanner else { return }

		// 初始位置在顶部外面
		banner.transform = CGAffineTransform(translationX: 0, y: -20)
		banner.alpha = 0

		UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
			banner.transform = .identity
			banner.alpha = 1
		}, completion: nil)
	}

	private func scheduleBannerDismiss(delay: TimeInterval) {
		timerBanner?.invalidate()
		timerBanner = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
			guard let self = self else { return }
			self.hideBanner()
		}
	}
}

// MARK: - Hide Banner
extension ProgressHUD {

	@objc func hideBanner() {
		guard let banner = viewBanner else { return }

		removeBannerObserver()

		UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
			banner.transform = CGAffineTransform(translationX: 0, y: -20)
			banner.alpha = 0
		}, completion: { _ in
			self.removeBanner()
		})
	}
}

// MARK: - Remove Banner
extension ProgressHUD {

	private func removeBanner() {
		// 移除阻塞层
		main.subviews.first(where: { $0.tag == 9999 })?.removeFromSuperview()

		labelBannerMessage?.removeFromSuperview()
		labelBannerTitle?.removeFromSuperview()
		bannerIconView?.removeFromSuperview()
		bannerCloseButton?.removeFromSuperview()
		viewBanner?.removeFromSuperview()

		labelBannerMessage = nil
		labelBannerTitle = nil
		bannerIconView = nil
		bannerCloseButton = nil
		viewBanner = nil
		bannerType = nil
		bannerIcon = nil
		bannerDismissible = true
		bannerInteraction = true
	}
}

// MARK: - Orientation Observer
extension ProgressHUD {

	private func removeBannerObserver() {
		if let observer = observerBanner {
			NotificationCenter.default.removeObserver(observer)
		}
	}

	private func createBannerObserver() {
		observerBanner = NotificationCenter.default.addObserver(forName: orientationDidChange, object: nil, queue: .main) { notification in
			// Banner 使用 Auto Layout，会自动适配旋转
			// 不需要额外处理
		}
	}
}
