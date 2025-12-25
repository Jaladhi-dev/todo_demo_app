# Todo App Assessment

Hello! I have created this simple Todo App to show my skills in Flutter BLoC and Clean Architecture.

This app is basically for managing daily tasks. Main feature is that it is working fully offline also. If your internet is not working, data will save in local database. When internet connection comes back, it will automatically sync data with the server.

### Features
- **Task List**: You can see all your pending works here.
- **CRUD Operations**: Add, Edit and Delete tasks easily.
- **Offline Mode**: If net is off, app will still work properly.
- **Auto Sync**: Data will upload to server when you are online.
- **Search**: Simple search option to find your tasks.

### How to Run Project

1. First, check if Flutter is installed in your system.
2. Clone this repository to your laptop.
3. Run command `flutter pub get` to download all packages.
4. Then run `flutter run` to start the application.

> **Important Note:** You need a mock server for API to work properly. I suggest using `json-server` on port 3000 (check `api_constants.dart` file).

### Technologies Used
- **Flutter**: For making the UI.
- **BLoC**: For managing state of the app.
- **Dio**: For calling APIs.
- **Sqflite**: For saving data locally.
- **GetIt**: For dependency injection.

