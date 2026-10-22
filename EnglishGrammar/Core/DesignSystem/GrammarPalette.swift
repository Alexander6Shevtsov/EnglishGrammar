import UIKit

enum GrammarPalette {
    static let background = UIColor(red: 0.035, green: 0.067, blue: 0.078, alpha: 1)
    static let surface = UIColor(red: 0.071, green: 0.124, blue: 0.145, alpha: 1)
    static let surfaceRaised = UIColor(red: 0.095, green: 0.164, blue: 0.190, alpha: 1)
    static let textPrimary = UIColor(red: 0.95, green: 0.98, blue: 0.99, alpha: 1)
    static let textSecondary = UIColor(red: 0.68, green: 0.79, blue: 0.83, alpha: 1)
    static let turquoise = UIColor(red: 0.10, green: 0.93, blue: 0.79, alpha: 1)
    static let mint = UIColor(red: 0.18, green: 0.86, blue: 0.42, alpha: 1)
    static let blue = UIColor(red: 0.22, green: 0.60, blue: 0.98, alpha: 1)
    static let purple = UIColor(red: 0.63, green: 0.40, blue: 1.0, alpha: 1)
    static let orange = UIColor(red: 1.0, green: 0.48, blue: 0.19, alpha: 1)
    static let error = UIColor(red: 1.0, green: 0.34, blue: 0.38, alpha: 1)

    static func accent(for name: String) -> UIColor {
        switch name {
        case "blue": return blue
        case "purple": return purple
        case "orange": return orange
        default: return mint
        }
    }
}

extension UILabel {
    static func grammarLabel(size: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = GrammarPalette.textPrimary) -> UILabel {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: size, weight: weight))
        label.adjustsFontForContentSizeCategory = true
        label.textColor = color
        label.numberOfLines = 0
        return label
    }
}

extension UIStackView {
    static func vertical(spacing: CGFloat = 12) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = spacing
        stack.alignment = .fill
        return stack
    }
}
