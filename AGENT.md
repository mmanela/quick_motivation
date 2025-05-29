# AGENT.md - Quick Motivation Development Guide

## Build/Test Commands
- **Build**: `xcodebuild -project src/self-motivation.xcodeproj -scheme self-motivation build`
- **Test all**: `xcodebuild -project src/self-motivation.xcodeproj -scheme self-motivation test`
- **Run single test**: `xcodebuild -project src/self-motivation.xcodeproj -scheme self-motivation test -only-testing:self_motivation_tests/TestClassName/testMethodName`
- **Build for release**: `xcodebuild -project src/self-motivation.xcodeproj -scheme self-motivation -configuration Release build`

## Code Style Guidelines

### Imports
- Standard imports: `Foundation`, `SwiftUI` 
- Use explicit imports, avoid `import *`

### Naming Conventions
- Constants: `ALL_CAPS_SNAKE_CASE` (e.g., `CUSTOM_MESSAGES_KEY`, `DEFAULT_PINNED_MESSAGE`)
- Configuration keys: `*_KEY` suffix
- Default values: `DEFAULT_*` prefix
- Variables/functions: `camelCase`
- Classes/structs: `PascalCase`

### Swift Conventions
- Use `private` for internal methods/properties
- Use `@AppStorage` for UserDefaults
- Use `@Binding` for two-way data binding
- Use `weak self` in closures to avoid retain cycles
- Use `guard let` for early returns and optional unwrapping
