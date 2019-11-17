import UIKit
import PlaygroundSupport
import SwiftSoup

func writeToFile(string: String, name: String) {
    print("\n\n\n\n\n\n")
    print(string)
}

// Models

struct Speaker: Codable {
    let id: String
    let firstname: String
    let lastname: String
    let image: String?
    let twitter: String?
    let github: String?
    let about: String?
}

struct Conference: Codable {
    let id: String
    let organisatorId: String
    let name: String?
    let url: String?
    let location: String?
    let date: String?
    let highlightColor: String?
    let about: String?
}

struct Talk: Codable {
    let id: String
    let conferenceId: String
    let speakerId: String
    let title: String
    let url: String?
    let source: String
    let videoId: String
    let details: String?
    let tags: [String]?
}


var speakers: [Speaker] = []
var conferences: [Conference] = []
var talks: [Talk] = []

extension String {
    func slice(from: String, to: String) -> String? {

        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

func loadJSON(with name: String) -> Data {
    guard let path = Bundle.main.path(forResource: name, ofType: "json"),
       let data = FileManager.default.contents(atPath: path) else {
           fatalError("Can not get json data")
       }

    return data
}

func loadExistingModels() {
    do {
        speakers = try JSONDecoder().decode([Speaker].self, from: loadJSON(with: "speaker"))
        conferences = try JSONDecoder().decode([Conference].self, from: loadJSON(with: "conference"))
        talks = try JSONDecoder().decode([Talk].self, from: loadJSON(with: "talk"))
    } catch {
        fatalError()
    }
}

loadExistingModels()


let url = "https://www.youtube.com/watch?v=M7GOoZMMrnY&list=PLdr22uU_wISr-FYeKblv3LMe_kHFzRFBw"

func downloadHTML() {
    // url string to URL
    guard let url = URL(string: url) else {
        // an error occurred
        fatalError()
    }

    do {
        let html = try String.init(contentsOf: url)
        let document = try SwiftSoup.parse(html)
        let elements = try document.select(".yt-uix-scroller-scroll-unit")

        parse(elements)
    } catch let error {
        fatalError(error.localizedDescription)
    }
}

downloadHTML()

func createSpeaker(name: String) -> String {
    let s = name.split(separator: " ")


    let firstName = String(s.first ?? "" )
    let lastName = String(s.last ?? "")

    guard !firstName.isEmpty && !lastName.isEmpty else {
        return "5bbd7fb61c205ad54d6d26c5f44d5b08961024ac"
    }

    let id = NSUUID().uuidString.lowercased()
    let speaker = Speaker(id: id, firstname: firstName, lastname: lastName, image: nil, twitter: nil, github: nil, about: nil)


    speakers.append(speaker)

    return id
}

func parse(_ elements: Elements) {
    do {
        for element in elements.array() {
            let title = try element.select(".yt-ui-ellipsis-2").text()
            let id = try element.html().slice(from: "v=", to: "&") ?? ""


            if title.isEmpty && id.isEmpty {
                continue
            }
            var name = title.replacingOccurrences(of: "UIKonf 2019 - Day 1", with: "")
            var aaa = name.replacingOccurrences(of: "UIKonf 2019 - Day 2", with: "")
            name = aaa.slice(from: "- ", to: " -")!
            let speaker = speakers.first(where: { name.contains("\($0.firstname) \($0.lastname)") } )
            var speakerId = "5bbd7fb61c205ad54d6d26c5f44d5b08961024ac"

            if speaker != nil {
                speakerId = speaker!.id
            } else {
              //  if name {
                    speakerId = createSpeaker(name: String(name))
            //    } else {
     //               speakerId = "5bbd7fb61c205ad54d6d26c5f44d5b08961024ac"
            //    }
           }

            let nextId = NSUUID().uuidString.lowercased()

           let talk = Talk(
                id: nextId,
                conferenceId: "7fc9e26d957641a6b949bdf55615ab3e",
                speakerId: speakerId,
                title: aaa.replacingOccurrences(of: name, with: ""),
                url: nil,
                source: "youtube",
                videoId: id,
                details: nil,
                tags: []
            )

            talks.append(talk)
        }

        writeToFile(string: String(data: try! JSONEncoder().encode(talks), encoding: .utf8) ?? "", name: "talks.json")
        writeToFile(string: String(data: try! JSONEncoder().encode(speakers), encoding: .utf8) ?? "", name: "speakers.json")

    } catch {
        fatalError("errr")
    }
}
