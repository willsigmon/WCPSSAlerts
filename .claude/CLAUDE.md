# WCPSS Alerts

iOS app for NC Triangle school closure predictions and weather alerts.

## Tech Stack
- SwiftUI, Swift 6, iOS 18+
- XcodeGen, WeatherKit, APNs
- @Observable ViewModels, async/await
- Token-based design system

## Commands
```bash
make xcodegen    # Generate Xcode project
make sim-build   # Build for simulator
make test        # Run tests
make format      # Format code
```

## User Preferences

### Workflow
- Autonomous execution, parallel agents when possible
- Haiku/Sonnet only (no Opus)
- Use Sosumi MCP for Apple API lookups

### Code Standards
- Immutability enforced, 800 line max
- No print() in committed code
- No hardcoded values
