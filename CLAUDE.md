# WCPSS Alerts iOS App

## Overview
iOS companion app for iswcpssclosed.com - NC Triangle school closure predictions.

## Tech Stack
- SwiftUI + @Observable (Swift 6)
- iOS 18.0 minimum
- XcodeGen for project generation
- WeatherKit for weather data
- APNs for push notifications

## Commands

```bash
# Generate Xcode project
make xcodegen

# Build for simulator
make sim-build

# Run on simulator
make sim-run

# Run tests
make test

# Format code
make format

# Lint code
make lint
```

## Architecture
- **@Observable ViewModels** - Not TCA, simpler state management
- **DIContainer.shared** - Singleton service locator
- **Async/await** - No Combine for new code
- **Token-based design system** - ColorTokens, TypographyTokens, SpacingTokens

## Key Files
- `App/AppViewModel.swift` - Root app state
- `Core/DependencyInjection/DIContainer.swift` - Service container
- `Core/Services/AlertService.swift` - Main prediction API
- `DesignSystem/Tokens/` - Design tokens
- `Features/Dashboard/` - Main screen

## API
Backend: https://iswcpssclosed.com/api
- GET /prediction - Current closure prediction
- GET /alerts - Recent alerts history

## Districts Covered
- WCPSS (Wake County)
- DPS (Durham)
- CHCCS (Chapel Hill-Carrboro)
- JCPS (Johnston County)
- OCPS (Orange County)
- GCPS (Granville County)
