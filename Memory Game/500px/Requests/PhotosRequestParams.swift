//
//  PhotosRequestParams.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 14.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

enum PhotosFeature: String {
    case popular = "popular"
    case highestRated = "highest_rated"
    case upcoming = "upcoming"
    case editors = "editors"
    case freshToday = "fresh_today"
    case freshYesterday = "fresh_yesterday"
    case freshWeek = "fresh_week"
    case user = "user"
    case userFriends = "user_friends"
}

enum PhotosSorting: String {
    case none = ""
    case createdAt = "created_at"
    case rating = "rating"
    case highestRating = "highest_rating"
    case timesViewed = "times_viewed"
    case votesCount = "votes_count"
    case commentsCount = "comments_count"
    case takenAt = "taken_at"
}

enum SortingOrder: String {
    case asc = "asc"
    case desc = "desc"
}
