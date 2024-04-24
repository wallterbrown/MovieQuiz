//
//  Movie.swift
//  MovieQuiz
//
//  Created by Всеволод Нагаев on 12.04.2024.
//

import Foundation

struct Actor: Codable {
    let id: String
    let image: String
    let name: String
    let asCharacter: String
}

struct Movie: Codable {
    // создаём кастомный enum для обработки ошибок
    enum ParseError: Error {
        case yearFailure
        case runtimeMinsFailure
    }
    let id: String
    let title: String
    let year: Int
    let image: String
    let releaseDate: String
    let runtimeMins: Int
    let directors: String
    let actorList: [Actor]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)

        let year = try container.decode(String.self, forKey: .year)
        guard let yearValue = Int(year) else {
            throw ParseError.yearFailure
        }
        self.year = yearValue

        image = try container.decode(String.self, forKey: .image)
        releaseDate = try container.decode(String.self, forKey: .releaseDate)

        let runtimeMins = try container.decode(String.self, forKey: .runtimeMins)
        guard let runtimeMinsValue = Int(runtimeMins) else {
            throw ParseError.runtimeMinsFailure
        }
        self.runtimeMins = runtimeMinsValue

        directors = try container.decode(String.self, forKey: .directors)
        actorList = try container.decode([Actor].self, forKey: .actorList)
    }
    
    
    
}

enum CodingKeys: CodingKey {
    case id, title, year, image, releaseDate, runtimeMins, directors, actorList
}
/*func getMovie(from jsonString: String) -> Movie? {
    var movie: Movie? = nil
    do {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        guard let json = json,
              let id = json["id"] as? String,
              let title = json["title"] as? String,
              let jsonYear = json["year"] as? String,
              let year = Int(jsonYear),
              let image = json["image"] as? String,
              let releaseDate = json["releaseDate"] as? String,
              let jsonRuntimeMins = json["runtimeMins"] as? String,
              let runtimeMins = Int(jsonRuntimeMins),
              let directors = json["directors"] as? String,
              let actorList = json["actorList"] as? [Any] else {
            return nil
        }

        var actors: [Actor] = []

        for actor in actorList {
            guard let actor = actor as? [String: Any],
                  let id = actor["id"] as? String,
                  let image = actor["image"] as? String,
                  let name = actor["name"] as? String,
                  let asCharacter = actor["asCharacter"] as? String else {
                return nil
            }
            let mainActor = Actor(id: id,
                                  image: image,
                                  name: name,
                                  asCharacter: asCharacter)
            actors.append(mainActor)
        }
        movie = Movie(id: id,
                      title: title,
                      year: year,
                      image: image,
                      releaseDate: releaseDate,
                      runtimeMins: runtimeMins,
                      directors: directors,
                      actorList: actors)
    } catch {
        print("Failed to parse: \(jsonString)")
    }

    return movie
}
*/
