# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A cross-platform Todo list application built with Flutter. The app persists tasks to JSON files in the user's home directory (`~/.todo/todo.json` for active tasks, `~/.todo/done.json` for completed tasks).

## Development Commands

### Running the app
```bash
flutter run              # Run on connected device/emulator
flutter run -d macos     # Run specifically on macOS
flutter run -d windows   # Run specifically on Windows
flutter run -d linux     # Run specifically on Linux
flutter run -d android   # Run on connected Android device
```

### Building
```bash
flutter build macos      # Build macOS app
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app
```

### Analysis & Linting
```bash
flutter analyze          # Run static analysis on the code
flutter format lib/      # Format Dart code
```

### Dependencies
```bash
flutter pub get          # Install dependencies
flutter pub upgrade      # Upgrade dependencies
```

## Architecture

### Entry Point (lib/main.dart)
- `main()` initializes the app with platform-specific setup:
  - Desktop (macOS/Linux/Windows): Sets up window manager with custom title bar, system tray integration, and close-button interception (minimizes to tray instead of closing)
  - Mobile (iOS/Android): Uses app documents directory for data storage
- Creates `TaskDriver` with paths to todo/done JSON files
- All UI widgets are passed the `TaskDriver` instance for data operations

### Data Layer (lib/task.dart)
- `Task`: Model class with `id`, `text`, and `finished` properties. Uses `uuid` package for unique IDs.
- `TaskDriver`: Singleton-like class managing all CRUD operations:
  - `getTask(finished)`: Retrieve tasks (active or completed)
  - `addTask(Task)`: Add a new task
  - `update(Task)`: Update an existing task's text
  - `removeTask(Task)`: Delete a task
  - `finish(Task)`: Move task from active to completed list
  - `unfinish(Task)`: Move task from completed back to active list
- All operations write JSON to disk with 2-space indentation

### UI Components
- `TodoList`: Main screen with input field and task lists. Maintains two lists: active `tasks` and `finishedList`. The finished list can be collapsed/expanded via `ExpandButton`.
- `TodoItem`: Individual task row with checkbox, editable text field, and delete button. Callbacks for update/delete are passed from parent.
- `ExpandButton`: Collapsible button to show/hide completed tasks.
- `window.dart`: Desktop-only window management and system tray setup (menu with "Exit" option)

### Platform-Specific Behavior
The app conditionally initializes window_manager and system_tray only on desktop platforms. Mobile platforms skip this setup and use the app documents directory for storage.

## Key Dependencies
- `window_manager`: Desktop window control (minimize, close prevention, custom title bar)
- `system_tray`: System tray icon and menu
- `path_provider`: Cross-platform directory paths (for mobile app documents)
- `uuid`: Unique ID generation for tasks
