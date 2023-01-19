# MVPCodeChallenge
To run the app please select 'MoviesIOSApp' scheme.

<img width="1278" alt="image" src="https://user-images.githubusercontent.com/16016161/213523781-31f8d0cd-19a7-4fc7-a900-033afb07be60.png">

# Key points
- Inside out approach by building domain layer first
- Domain layer is agnostic from platforms and frameworks. It can be used with iOS, MacOs, WatchOs.
- 100% test coverage for domain layer (Unit & Integration tests)
- 100% Tested Networking layer with HTTPClient, any third party framework can replace HTTPClient without affecting other components.
- 100% Tested persistence layer with CoreData, any persistence framework can replace CoreData without affecting other components.
- All infrastructure implementation is separate from business logic, infrastructure implementation just obey the commands.
- Independent UI layer with UIKit. UIKit classes do not depend on any framework 
- Independent reusable ViewModels. ViewModels do not depend on UIKit elements
- Image loading implementation can be updated/modified with any Image loading client.
- All dependencies managed from the composition route. ViewControllers don't know about the navigation or other logic. They just obey the commands to display data.
- All threading handled from composition route using decorator pattern.
- Independent schemes for each test target to keep blazing fast unit tests separate from slow integration tests
- CI scheme with all test targets to be used in CI pipelines.


# Movie API

Following public movies API being used in this project https://www.themoviedb.org/documentation/api
### Search API URL
'https://api.themoviedb.org/3/search/movie?api_key=08d9aa3c631fbf207d23d4be591ccfc3&language=en-US&page=1&include_adult=false&query= search string here'
