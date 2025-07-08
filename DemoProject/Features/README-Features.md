# Features Documentation

This directory contains the main features of the application, organized using MVVM (Model-View-ViewModel) architecture.

## Structure

```
Features/
├── View/        # SwiftUI Views
└── ViewModel/   # View Models for business logic
```

## Architecture

The features follow the MVVM (Model-View-ViewModel) pattern:

1. **Views** (`View/`)
   - SwiftUI views
   - Handle UI layout and user interactions
   - Observe ViewModels for state updates

2. **ViewModels** (`ViewModel/`)
   - Business logic
   - State management
   - Data transformation
   - Communication with Domain layer

## Best Practices

### Views
- Keep views simple and focused on UI
- Use SwiftUI previews for rapid development
- Follow SwiftUI lifecycle guidelines
- Implement proper view composition

### ViewModels
- Use `@Published` for observable state
- Implement proper error handling
- Keep business logic separate from UI
- Use dependency injection

## Adding New Features

When adding a new feature:

1. Create a new directory under both View/ and ViewModel/
2. Follow the existing naming conventions
3. Implement the feature using MVVM pattern
4. Add appropriate unit tests
5. Update documentation

## Testing

- Each ViewModel should have corresponding unit tests
- Use SwiftUI previews for visual testing
- Implement UI tests for critical user flows

## Dependencies

Features may depend on:
- Core components
- Domain models
- Platform services

Always maintain loose coupling between features and their dependencies. 