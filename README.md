# spm-create-xcframework
Github Action to create XCFramework for Swift package product. Right now the action only supports dynamic frameworks (it will add/overwrite the product type to be `.dynamic` in the Package.swift file.

## Example:
### .github/workflows/create_xcframework.yml

```yaml
name: Create XCFramework

# Create XCFramework when a new tag is pushed
on:
  push:
    tags:

jobs:
  create_xcframework:
    name: Create XCFramework
    runs-on: macos-latest
    steps:

      - uses: actions/checkout@v2

      - name: Create XCFramework
        uses: mohamed-3amer/spm-create-xcframework@v1.0.0
```

## Action Inputs
- **target**: The product name you want to create an XCFramework for.
- **zip-version**: The version number to append to the name of the zip file.
- **output-path**: A path where to save the output files locally for later usage.

## Contributing

Please read the [Contribution Guide](CONTRIBUTING.md) for details on how to contribute to this project.

## References
- https://forums.swift.org/t/how-to-build-swift-package-as-xcframework/41414/4
