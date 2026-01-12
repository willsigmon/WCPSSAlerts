.PHONY: all build clean test xcodegen format lint sim-build sim-run

# Project configuration
PROJECT_NAME = WCPSSAlerts
SCHEME = WCPSSAlerts
PLATFORM = iOS Simulator
DEVICE = iPhone 16 Pro
OS_VERSION = 18.0

# Generate Xcode project from project.yml
xcodegen:
	xcodegen generate

# Build for simulator
sim-build: xcodegen
	xcodebuild \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination "platform=$(PLATFORM),name=$(DEVICE),OS=$(OS_VERSION)" \
		-configuration Debug \
		build

# Run on simulator
sim-run: sim-build
	xcrun simctl boot "$(DEVICE)" 2>/dev/null || true
	xcrun simctl install "$(DEVICE)" "$$(xcodebuild -project $(PROJECT_NAME).xcodeproj -scheme $(SCHEME) -showBuildSettings | grep -m 1 'BUILT_PRODUCTS_DIR' | awk '{print $$3}')/$(PROJECT_NAME).app"
	xcrun simctl launch "$(DEVICE)" com.wcpss.$(PROJECT_NAME)

# Build for device
build: xcodegen
	xcodebuild \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination "generic/platform=iOS" \
		-configuration Release \
		build

# Run tests
test: xcodegen
	xcodebuild \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination "platform=$(PLATFORM),name=$(DEVICE),OS=$(OS_VERSION)" \
		-configuration Debug \
		test

# Clean build artifacts
clean:
	xcodebuild clean -project $(PROJECT_NAME).xcodeproj -scheme $(SCHEME)
	rm -rf DerivedData/
	rm -rf build/

# Format Swift code
format:
	swiftformat . --config .swiftformat 2>/dev/null || swiftformat .

# Lint Swift code
lint:
	swiftlint

# CI test (strict)
ci-test: xcodegen
	xcodebuild \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination "platform=$(PLATFORM),name=$(DEVICE),OS=$(OS_VERSION)" \
		-configuration Debug \
		-resultBundlePath TestResults.xcresult \
		test

# Verify project compiles
verify: xcodegen
	xcodebuild \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination "platform=$(PLATFORM),name=$(DEVICE),OS=$(OS_VERSION)" \
		-configuration Debug \
		build | xcpretty || xcodebuild \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination "platform=$(PLATFORM),name=$(DEVICE),OS=$(OS_VERSION)" \
		-configuration Debug \
		build

# Help
help:
	@echo "Available targets:"
	@echo "  xcodegen   - Generate Xcode project"
	@echo "  sim-build  - Build for simulator"
	@echo "  sim-run    - Build and run on simulator"
	@echo "  build      - Build for device (Release)"
	@echo "  test       - Run unit tests"
	@echo "  clean      - Clean build artifacts"
	@echo "  format     - Format code with SwiftFormat"
	@echo "  lint       - Lint code with SwiftLint"
	@echo "  verify     - Verify project compiles"
