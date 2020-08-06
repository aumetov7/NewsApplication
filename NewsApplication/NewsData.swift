//
//  NewsData.swift
//  NewsApplication
//
//  Created by Акбар Уметов on 05.08.2020.
//  Copyright © 2020 Akbar Umetov. All rights reserved.
//

import Foundation

// MARK: - NewsData
struct NewsData: Codable {
    let count: Int
    let next: String
    let previous: String?
    let results: [Result]
}

// MARK: - Result
struct Result: Codable {
    let id, publicationDate: Int
    let title, slug: String
    let resultDescription, bodyText: String
    let images: [Image]
    let siteURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case publicationDate = "publication_date"
        case title, slug
        case resultDescription = "description"
        case bodyText = "body_text"
        case images
        case siteURL = "site_url"
    }
}

// MARK: - Image
struct Image: Codable {
    let image: String
    let source: Source
}

// MARK: - Source
struct Source: Codable {
    let name: String
    let link: String
}
