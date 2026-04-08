import UIKit

// MARK: - Keyboard Extension
// Shows recently copied ReviewReply responses in a keyboard accessory.
// Users tap a response to insert it directly into any text field (Google Maps, Yelp in-app, etc.)
//
// Enable in Settings → General → Keyboard → Keyboards → Add New Keyboard → ReviewReply Keys
// RequestsOpenAccess = false means no internet permission is needed (reads shared group only).

final class KeyboardViewController: UIInputViewController {

    // MARK: - Properties

    private var responses: [String] = []
    private let sharedGroup  = "group.com.reviewreply.shared"
    private let responsesKey = "com.reviewreply.recentResponses"

    private var scrollView: UIScrollView!
    private var stackView: UIStackView!
    private var emptyLabel: UILabel!
    private var nextKeyboardButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadResponses()
        rebuildResponseButtons()
    }

    // MARK: - Data

    private func loadResponses() {
        let defaults = UserDefaults(suiteName: sharedGroup)
        responses = defaults?.stringArray(forKey: responsesKey) ?? []
    }

    // MARK: - UI Construction

    private func buildUI() {
        view.backgroundColor = UIColor.secondarySystemBackground

        // ── Next Keyboard Button ──────────────────────────────────────────
        nextKeyboardButton = UIButton(type: .system)
        nextKeyboardButton.setTitle("🌐", for: .normal)
        nextKeyboardButton.titleLabel?.font = .systemFont(ofSize: 22)
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextKeyboardButton)

        // ── Header ────────────────────────────────────────────────────────
        let headerLabel = UILabel()
        headerLabel.text = "ReviewReply"
        headerLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        headerLabel.textColor = .secondaryLabel
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)

        // ── Empty State Label ─────────────────────────────────────────────
        emptyLabel = UILabel()
        emptyLabel.text = "No saved replies yet.\nCopy a reply in ReviewReply to see it here."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 13)
        emptyLabel.textColor = .tertiaryLabel
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        // ── Scroll + Stack ────────────────────────────────────────────────
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        // ── Layout ────────────────────────────────────────────────────────
        NSLayoutConstraint.activate([
            // Height of the entire keyboard view
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: 220),

            nextKeyboardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            nextKeyboardButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),

            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),

            scrollView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            emptyLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20)
        ])
    }

    private func rebuildResponseButtons() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emptyLabel.isHidden = !responses.isEmpty

        for (i, text) in responses.enumerated() {
            let btn = ResponseButton(text: text, index: i)
            btn.addTarget(self, action: #selector(insertResponse(_:)), for: .touchUpInside)
            btn.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(btn)
        }
    }

    // MARK: - Actions

    @objc private func insertResponse(_ sender: ResponseButton) {
        textDocumentProxy.insertText(sender.responseText)

        // Brief visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            sender.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.15) { sender.alpha = 1 }
        }
    }
}

// MARK: - Response Button

private final class ResponseButton: UIButton {

    let responseText: String

    init(text: String, index: Int) {
        self.responseText = text
        super.init(frame: .zero)
        configure(text: text)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func configure(text: String) {
        var config = UIButton.Configuration.filled()
        config.title                  = text
        config.titleLineBreakMode     = .byTruncatingTail
        config.titleAlignment         = .leading
        config.cornerStyle            = .medium
        config.baseBackgroundColor    = .systemBackground
        config.baseForegroundColor    = .label
        config.contentInsets          = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
        configuration = config

        titleLabel?.font              = .systemFont(ofSize: 13)
        titleLabel?.numberOfLines     = 2
        titleLabel?.lineBreakMode     = .byTruncatingTail
        contentHorizontalAlignment    = .leading

        layer.cornerRadius            = 10
        layer.borderWidth             = 0.5
        layer.borderColor             = UIColor.separator.cgColor
    }
}
