import Foundation

class TopSites {
    // Define constants
    let maxResults = 10
    let url = URL(string: "https://example.com/topsites.json")! // Replace with your own API endpoint

    // Define a completion handler for fetching top sites
    typealias TopSitesCompletionHandler = ([String]) -> Void

    // Fetch top sites and call completion handler
    func fetchTopSites(completionHandler: @escaping TopSitesCompletionHandler) {
        // Create a URL request with headers and parameters as needed
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"

        // Send the request using URLSession and process the response
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching top sites: \(error.localizedDescription)")
                completionHandler([])
            } else if let data = data,
                      let sites = try? JSONDecoder().decode([String].self, from: data) {
                completionHandler(Array(sites.prefix(self.maxResults)))
            } else {
                completionHandler([])
            }
        }.resume()
    }
}
