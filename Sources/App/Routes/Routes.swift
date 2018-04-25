import Vapor
import Foundation

// http://iptvgratuit.com/iptv-m3u/fr-2018-04-22.m3u

extension Droplet {
    func setupRoutes() throws {

        group("") { iptv in
            iptv.get("") { _ -> Response in
                return Response(status: .ok, body: ":)")
            }

            iptv.get(":country") { req -> Response in
                guard var country = req.parameters["country"]?.string else {
                    return Response(status: .notFound, body: "Not found")
                }
                if country.hasSuffix(".m3u") {
                    country = String(country.dropLast(".m3u".count))
                }

                var client: Response?
                var body: Bytes?
                var mustContinue = true
                var minusDays: Int = 0

                while mustContinue {
                    let date = Calendar.current.date(byAdding: .day, value: minusDays,
                                                     to: Date(),
                                                     wrappingComponents: true)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateString = dateFormatter.string(from: date!)

                    client = try self.client.get("http://iptvgratuit.com/iptv-m3u/\(country)-\(dateString).m3u")

                    if client?.status.statusCode == 200 {
                        mustContinue = false
                        body = client?.body.bytes!
                    } else {
                        minusDays -= 1
                    }

                    if minusDays < -5 {
                        return Response(status: .notFound, body: "Not found")
                    }
                }

                let output = Response(status: .ok, body: body!)

                return output
            }
        }

    }
}
