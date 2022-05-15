PLATFORM_IOS = iOS Simulator,name=iPhone 13,OS=15.0

.PHONY: archive
archive:
	@if [ -d .build/archive.xcarchive ]; then \
		set -o pipefail && rm -rf .build/archive.xcarchive | echo "Deleted archive"; \
	fi
	@agvtool next-version -all
	@xcodebuild \
		-workspace wanlog-iOS.xcworkspace \
		-scheme "App (Staging project)" \
		-configuration Release \
		archive \
		-archivePath .build/archive \

.PHONY: debug-build
debug-build:
	@xcodebuild \
		-workspace wanlog-iOS.xcworkspace \
		-scheme "App (Staging project)" \
		-destination platform="$(PLATFORM_IOS)"

.PHONY: generate-license
generate-license:
	swift run -c release --package-path ./BuildTools license-plist --output-path App/Settings.bundle --package-paths ./Package.swift

.PHONY: swift-lint
swift-lint:
	swift run -c release --package-path ./BuildTools swift-format lint --configuration ./BuildTools/.swift-format -r ./Sources

.PHONY: swift-format
swift-format:
	swift run -c release --package-path ./BuildTools swift-format format --configuration ./BuildTools/.swift-format -r ./Sources -i

.PHONY: test
test:
	@xcodebuild test \
		-workspace wanlog-iOS.xcworkspace \
		-scheme "App (Staging project)" \
		-destination platform="$(PLATFORM_IOS)"
