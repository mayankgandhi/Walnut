import SwiftUI
import Gate
import WalnutDesignSystem

extension GateConfiguration {
    static var walnut: GateConfiguration {
        GateConfiguration(
            appName: "Walnut",
            premiumBrandName: "Walnut Pro",
            revenueCatAPIKey: "appl_UyfeaggCisDlNefCGPnvlcPWzcA",
            premiumFeatures: [
                PremiumFeature(
                    id: "unlimited_records",
                    title: "Unlimited Medical Records",
                    description: "Store unlimited patient records and medical cases",
                    icon: "folder.badge.plus"
                ),
                PremiumFeature(
                    id: "ai_document_parsing",
                    title: "AI Document Parsing",
                    description: "Advanced AI-powered document analysis and parsing",
                    icon: "doc.text.magnifyingglass"
                ),
                PremiumFeature(
                    id: "export_sharing",
                    title: "Export & Sharing",
                    description: "Export records and share with healthcare providers",
                    icon: "square.and.arrow.up"
                ),
                PremiumFeature(
                    id: "priority_support",
                    title: "Priority Support",
                    description: "Get priority customer support and updates",
                    icon: "headphones"
                ),
                PremiumFeature(
                    id: "advanced_analytics",
                    title: "Advanced Analytics",
                    description: "View detailed analytics and insights about your health data",
                    icon: "chart.bar.fill"
                ),
            ],
            accentColor: .healthPrimary,
            premiumGradient: [
                Color(uiColor: UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)),
                Color(uiColor: UIColor(red: 0.18, green: 0.18, blue: 0.22, alpha: 1))
            ],
            appIconName: "health-stack-pro"
        )
    }
}
