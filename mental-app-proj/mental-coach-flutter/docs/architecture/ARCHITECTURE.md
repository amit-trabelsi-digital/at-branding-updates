# Project Architecture

This document provides an overview of the project structure for the Mental Coach Flutter application.

## `lib` Directory Structure

The `lib` directory is the main folder containing the Dart code for the application. It is organized as follows:

-   **`main.dart`**: The entry point of the application. It initializes the app and the main routes.

-   **`/config`**: Contains configuration files, such as environment settings (`environment_config.dart`).

-   **`/data`**: Includes static or dummy data used throughout the application (e.g., `training_dummy_data.dart`).

-   **`/helpers`**: A collection of utility functions and helper classes that can be reused across the app.

-   **`/models`**: Defines the data structures and models used in the application (e.g., User, Match, Goal).

-   **`/providers`**: Manages the application's state using the Provider package. Each provider is responsible for a specific part of the app's state (e.g., `user_provider.dart`).

-   **`/router` / `/routes`**: Handles navigation and routing for the application, defining the available routes and their corresponding screens.

-   **`/screens`**: Contains the UI for each screen in the application, organized into subdirectories based on functionality:
    -   **/login**: Screens related to user authentication (login, registration, home).
    -   **/main**: The main screens after login, including the dashboard, profile, and other core features.
    -   **/general**: General-purpose screens like error pages.

-   **`/service`**: Contains services for interacting with external resources like APIs or databases (e.g., Firebase services).

-   **`/utils`**: Miscellaneous utility classes and functions.

-   **`/widgets`**: A library of reusable UI components (widgets) used to build the screens. This directory is further organized by widget type:
    -   **/buttons**: Custom button widgets.
    -   **/cards**: Card-based layout widgets.
    -   **/draws**: Custom painting and drawing widgets.
    -   **/layouts**: Widgets for structuring screen layouts.
    -   **/notifies**: Widgets for displaying notifications and alerts.
    -   **/players**: Widgets related to audio or video playback.
    -   **/selectors**: Widgets for selecting values (e.g., dropdowns, number selectors).
    -   **/tabs**: Widgets for creating tabbed navigation.
    -   Other common widgets are also available directly under `/widgets`.

-   **`firebase_options.dart`**: Auto-generated file for Firebase configuration. 