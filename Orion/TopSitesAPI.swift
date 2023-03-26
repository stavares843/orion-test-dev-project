import Foundation

protocol TopSitesAPI {
    func getTopSites() -> [String]
}

class HardcodedTopSitesAPI: TopSitesAPI {
    func getTopSites() -> [String] {
        return [
            "https://www.google.com",
            "https://www.youtube.com",
            "https://www.facebook.com",
            "https://www.wikipedia.org",
            "https://www.twitter.com",
            "https://www.amazon.com",
            "https://www.reddit.com",
            "https://www.instagram.com",
            "https://www.netflix.com",
            "https://www.linkedin.com"
        ]
    }
}
