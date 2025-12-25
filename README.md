# Todo App Assessment

Current version of the Todo App to demonstrate Flutter skills using BLoC and Clean Architecture.

This application allows users to manage their daily tasks. The main highlight is the offline capability - it works perfectly without internet and syncs up when you get back online.

## Setup Instructions for Flutter App

To run this project on your machine, follow these simple steps:

1.  **Prerequisites**: Make sure you have Flutter SDK installed and set up.
2.  **Clone Repo**: Download this repository to your local system.
3.  **Dependencies**: Open terminal in the project folder and run `flutter pub get`.
4.  **Run**: Connect a device or emulator and run `flutter run`.

> **Note**: This app expects a backend APIs. I have configured it to use `json-server` for testing. Please ensure your API server is running locally or update `api_constants.dart` with your live URL.

## Design Decisions & Assumptions

-   **Clean Architecture**: I split the code into Data, Domain, and Presentation layers. This makes the code easy to test and maintain.
-   **Dependency Injection**: Used `GetIt` to handle dependency injection so we don't have to pass services manually everywhere.
-   **Navigation**: Used simple routing initially, but ready for `GoRouter` if needing complex navigation.
-   **Assumption**: I assumed simpler conflict resolution for sync (server wins or last write wins) to keep things simple for this demo.

## BLoC Pattern Implementation

I used the BLoC (Business Logic Component) pattern to separate UI from logic.

-   **Events**: We have events like `LoadTasks`, `AddTask`, `UpdateTask`, etc.
-   **States**: The UI listens to states like `TaskLoading`, `TaskLoaded` (which has the list of todos), and `TaskError`.
-   **Flow**: UI sends an Event -> BLoC processes it (talks to UseCase/Repository) -> BLoC emits a State -> UI updates.

## Challenges Faced

One main challenge was **handling the offline sync**.
-   **Problem**: How to keep user experience smooth when internet goes off?
-   **Solution**: I implemented "Optimistic Updates". When you add or change a task, the UI updates immediately. If the server call fails later (because of no net), we just mark that item as "pending sync" in the local database. User doesn't feel any lag.

## Offline Support Strategy

The strategy is "Local First" with Sync.

1.  **Reading Data**: App always tries to get fresh data from server. If server fails or no internet, it immediately falls back to local SQLite database.
2.  **Writing Data**:
    -   When you create a todo, we save it locally first.
    -   Then we try to push to server.
    -   If server success -> Great, we update local data with server ID.
    -   If server fail (offline) -> We keep it locally but flag it as `isPendingSync`.
3.  **Syncing**: When app detects internet connection, it checks for any records with `isPendingSync` and pushes them to the server automatically.
