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

		// Setup banner view with glass effect
		viewBanner = UIToolbar()
		viewBanner?.isTranslucent = true
		viewBanner?.clipsToBounds = true
		viewBanner?.layer.cornerRadius = 32
		viewBanner?.backgroundColor = colorBanner

		// Create container stack view for layout
		let containerStack = UIStackView()
		containerStack.axis = .horizontal
		containerStack.alignment = .center
		containerStack.spacing = 8
		containerStack.translatesAutoresizingMaskIntoConstraints = false

		// Setup icon if needed
		if let bannerType = bannerType {
			let iconView = createBannerIcon(for: bannerType)
			containerStack.addArrangedSubview(iconView)
		}

		// Create vertical stack for title and message
		let textStack = UIStackView()
		textStack.axis = .vertical
		textStack.alignment = .leading
		textStack.spacing = 4
		textStack.translatesAutoresizingMaskIntoConstraints = false

		// Setup title label
		if !textBannerTitle.isEmpty {
			labelBannerTitle = UILabel()
			labelBannerTitle?.text = textBannerTitle
			labelBannerTitle?.font = fontBannerTitle
			labelBannerTitle?.textColor = colorBannerTitle
			labelBannerTitle?.numberOfLines = 1
			textStack.addArrangedSubview(labelBannerTitle!)
		}

		// Setup message label
		if !textBannerMessage.isEmpty {
			labelBannerMessage = UILabel()
			labelBannerMessage?.text = textBannerMessage
			labelBannerMessage?.font = fontBannerMessage
			labelBannerMessage?.textColor = colorBannerMessage
			labelBannerMessage?.numberOfLines = 4
			textStack.addArrangedSubview(labelBannerMessage!)
		}

		containerStack.addArrangedSubview(textStack)

		// Setup dismiss button if dismissible
		if bannerDismissible {
			bannerDismissButton = UIButton(type: .system)
			bannerDismissButton?.setImage(UIImage(systemName: "xmark"), for: .normal)
			bannerDismissButton?.tintColor = colorBannerTitle.withAlphaComponent(0.6)
			bannerDismissButton?.addTarget(self, action: #selector(hideBanner), for: .touchUpInside)
			bannerDismissButton?.translatesAutoresizingMaskIntoConstraints = false
			containerStack.addArrangedSubview(bannerDismissButton!)

			NSLayoutConstraint.activate([
				bannerDismissButton!.widthAnchor.constraint(equalToConstant: 24),
				bannerDismissButton!.heightAnchor.constraint(equalToConstant: 24)
			])
		}

		if let viewBanner {
			main.addSubview(viewBanner)
			viewBanner.addSubview(containerStack)

			// Setup constraints
			NSLayoutConstraint.activate([
				containerStack.topAnchor.constraint(equalTo: viewBanner.topAnchor, constant: 12),
				containerStack.bottomAnchor.constraint(equalTo: viewBanner.bottomAnchor, constant: -12),
				containerStack.leadingAnchor.constraint(equalTo: viewBanner.leadingAnchor, constant: 16),
				containerStack.trailingAnchor.constraint(equalTo: viewBanner.trailingAnchor, constant: -16)
			])

			resizeBanner()

			// Animate in
			let y = viewBanner.frame.origin.y
			viewBanner.frame.origin.y = -100
			UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
				viewBanner.frame.origin.y = y
			}
		}

		// Setup background interaction layer
		if !bannerInteraction {
			let backgroundView = UIView(frame: main.bounds)
			backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.001)
			backgroundView.tag = 999 // Tag for later removal
			main.insertSubview(backgroundView, belowSubview: viewBanner!)
		}

		// Setup auto-dismiss timer
		if delay > 0 {
			timerBanner?.invalidate()
			timerBanner = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
				guard let self = self else { return }
				self.hideBanner()
			}
		}

		// Setup tap gesture if dismissible
		if bannerDismissible {
			let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideBanner))
			viewBanner?.addGestureRecognizer(tapGesture)
		}

		createBannerObserver()
	}

	private func createBannerIcon(for type: BannerType) -> UIView {
		let iconSize: CGFloat = 24
		let iconContainer = UIView()
		iconContainer.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			iconContainer.widthAnchor.constraint(equalToConstant: iconSize),
			iconContainer.heightAnchor.constraint(equalToConstant: iconSize)
		])

		switch type {
		case .loading:
			let activityIndicator = UIActivityIndicatorView(style: .medium)
			activityIndicator.color = colorBannerTitle
			activityIndicator.startAnimating()
			activityIndicator.translatesAutoresizingMaskIntoConstraints = false
			iconContainer.addSubview(activityIndicator)

			NSLayoutConstraint.activate([
				activityIndicator.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
				activityIndicator.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor)
			])

		case .success:
			bannerIcon = createIconImageView(systemName: "checkmark.circle")
		case .error:
			bannerIcon = createIconImageView(systemName: "xmark.circle")
		case .warning:
			bannerIcon = createIconImageView(systemName: "exclamationmark.bubble")
		case .info:
			bannerIcon = createIconImageView(systemName: "info.circle")
		}

		if let bannerIcon = bannerIcon {
			bannerIcon.translatesAutoresizingMaskIntoConstraints = false
			iconContainer.addSubview(bannerIcon)

			NSLayoutConstraint.activate([
				bannerIcon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
				bannerIcon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
				bannerIcon.widthAnchor.constraint(equalToConstant: iconSize),
				bannerIcon.heightAnchor.constraint(equalToConstant: iconSize)
			])
		}

		return iconContainer
	}

	private func createIconImageView(systemName: String) -> UIImageView {
		let imageView = UIImageView()
		let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
		imageView.image = UIImage(systemName: systemName, withConfiguration: config)
		imageView.tintColor = colorBannerTitle
		imageView.contentMode = .scaleAspectFit
		return imageView
	}
}

// MARK: - Hide Banner
extension ProgressHUD {

	@objc func hideBanner() {
		guard let banner = viewBanner else { return }

		removeBannerObserver()
		timerBanner?.invalidate()
		timerBanner = nil

		UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
			banner.frame.origin.y = -100
			banner.alpha = 0
		}, completion: { _ in
			self.removeBanner()
		})

		// Remove background interaction layer
		if let backgroundView = main.viewWithTag(999) {
			backgroundView.removeFromSuperview()
		}
	}
}

// MARK: - Remove Banner
extension ProgressHUD {

	private func removeBanner() {
		labelBannerMessage?.removeFromSuperview()
		labelBannerTitle?.removeFromSuperview()
		bannerIcon?.removeFromSuperview()
		bannerDismissButton?.removeFromSuperview()
		viewBanner?.removeFromSuperview()

		labelBannerMessage = nil
		labelBannerTitle = nil
		bannerIcon = nil
		bannerDismissButton = nil
		viewBanner = nil
		bannerType = nil
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
			DispatchQueue.main.async {
				self.resizeBanner()
			}
		}
	}
}

// MARK: - Banner Size
extension ProgressHUD {

	private func resizeBanner() {
		guard let viewBanner = viewBanner else { return }

		let widthBanner = main.frame.width - 32
		let heightBanner = calculateBannerHeight()

		viewBanner.frame = CGRect(x: 16, y: main.safeAreaInsets.top + 8, width: widthBanner, height: heightBanner)
	}

	private func calculateBannerHeight() -> CGFloat {
		let widthLabel = main.frame.width - 64 - (bannerType != nil ? 32 : 0) - (bannerDismissible ? 32 : 0)

		var height: CGFloat = 24 // Base padding

		// Calculate title height
		if !textBannerTitle.isEmpty {
			let titleSize = textBannerTitle.boundingRect(
				with: CGSize(width: widthLabel, height: .greatestFiniteMagnitude),
				options: [.usesLineFragmentOrigin, .usesFontLeading],
				attributes: [.font: fontBannerTitle],
				context: nil
			)
			height += ceil(titleSize.height)
		}

		// Calculate message height
		if !textBannerMessage.isEmpty {
			let messageSize = textBannerMessage.boundingRect(
				with: CGSize(width: widthLabel, height: .greatestFiniteMagnitude),
				options: [.usesLineFragmentOrigin, .usesFontLeading],
				attributes: [.font: fontBannerMessage],
				context: nil
			)
			height += ceil(messageSize.height)

			// Add spacing between title and message if both exist
			if !textBannerTitle.isEmpty {
				height += 4
			}
		}

		// Ensure minimum height
		return max(height, 48)
	}
}
