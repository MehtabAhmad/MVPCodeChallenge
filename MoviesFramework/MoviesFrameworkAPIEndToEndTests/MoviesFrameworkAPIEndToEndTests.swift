//
//  MoviesFrameworkAPIEndToEndTests.swift
//  MoviesFrameworkAPIEndToEndTests
//
//  Created by Mehtab on 02/01/2023.
//

import XCTest
import MoviesFramework

final class MoviesFrameworkAPIEndToEndTests: XCTestCase {
    
    /// These tests are not more reliable against real backend data which can be change and may break the tests. They should be written against fixed backend data which doesn't change. I added them against real backend data because they are helpful to guarantee that all networking components are working fine in integration and they are bringing the right data back, also they are helpful to insure the JSON contract between app and backend team
    
    func test_endToEndTestServerGETMovieResult_matchesFixedMovieData() {
        
        switch getMovieResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 1, "Expected 1 items in the test account feed")
            XCTAssertEqual(items[0], expectedItem(at: 0))

        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) instead")

        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }

    // MARK: - Helpers
    
    
    func getMovieResult() -> LoadMovieResult? {
        let url = URL(string:"https://api.themoviedb.org/3/search/movie?api_key=08d9aa3c631fbf207d23d4be591ccfc3&language=en-US&page=1&include_adult=false&query=Avatar:%20The%20Way%20of%20Water")!

        let client = URLSessionHTTPClient()
        let loader = RemoteMovieLoader(client: client, url: url)

        let exp = expectation(description: "Wait for load completion")

        var receivedResult: LoadMovieResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        
        return receivedResult
    }

    private func expectedItem(at index: Int) -> DomainMovie {
        return DomainMovie(
            id: id(at: index),
            title: title(at: index),
            description: description(at: index),
            poster: poster(at: index),
            rating: rating(at: index))
    }

    private func id(at index: Int) -> Int {
        return [
            76600
        ][index]
    }

    private func title(at index: Int) -> String {
        return [
            "Avatar: The Way of Water"
        ][index]
    }

    private func description(at index: Int) -> String {
        return [
            "Set more than a decade after the events of the first film, learn the story of the Sully family (Jake, Neytiri, and their kids), the trouble that follows them, the lengths they go to keep each other safe, the battles they fight to stay alive, and the tragedies they endure."
        ][index]
    }

    private func poster(at index: Int) -> URL {
        return [
            URL(string: "/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg")!
            ][index]
    }

    private func rating(at index: Int) -> Float {
        return [
            7.7
        ][index]
    }
    
}


// Mark :- API RESPONSE
//url = https://api.themoviedb.org/3/search/movie?api_key=08d9aa3c631fbf207d23d4be591ccfc3&language=en-US&page=1&include_adult=false&query=Avatar: The Way of Water"

/*{
    "page": 1,
    "results": [
        {
            "adult": false,
            "backdrop_path": "/s16H6tpK2utvwDtzZ8Qy4qm5Emw.jpg",
            "genre_ids": [
                878,
                12,
                28
            ],
            "id": 76600,
            "original_language": "en",
            "original_title": "Avatar: The Way of Water",
            "overview": "Set more than a decade after the events of the first film, learn the story of the Sully family (Jake, Neytiri, and their kids), the trouble that follows them, the lengths they go to keep each other safe, the battles they fight to stay alive, and the tragedies they endure.",
            "popularity": 5896.522,
            "poster_path": "/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg",
            "release_date": "2022-12-14",
            "title": "Avatar: The Way of Water",
            "video": false,
            "vote_average": 7.7,
            "vote_count": 3251
        }
    ],
    "total_pages": 1,
    "total_results": 1
}*/
