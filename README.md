# DemoProject

A modern iOS application built with SwiftUI following clean architecture principles.

## Project Structure

The project follows a modular architecture with clear separation of concerns:

```
DemoProject/
├── Core/           # Core utilities and shared components
├── Features/       # Feature modules of the application
├── Domain/         # Business logic and domain models
├── Platform/       # Platform-specific implementations
└── Preview Content/# SwiftUI preview assets
```

### Key Components

- `DemoProjectApp.swift`: The main entry point of the application
- `ContentView.swift`: The root view of the application
- `Core/`: Contains fundamental utilities and shared components
- `Features/`: Contains feature-specific modules
- `Domain/`: Houses business logic and domain models
- `Platform/`: Platform-specific implementations and services

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository
2. Open `DemoProject.xcodeproj` in Xcode
3. Build and run the project

## Architecture

This project follows Clean Architecture principles with the following layers:

1. **Presentation Layer** (SwiftUI Views)
   - Located in Features directory
   - Handles UI logic and user interactions

2. **Domain Layer**
   - Contains business logic
   - Defines interfaces and models

3. **Platform Layer**
   - Implements data sources
   - Handles external services and dependencies

## Testing

The project includes two test targets:
- `DemoProjectTests`: Unit tests
- `DemoProjectUITests`: UI tests

Run tests using Cmd+U in Xcode.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 