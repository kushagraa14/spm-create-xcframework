# spm-create-xcframework
Github Action to create XCFramework for Swift package dynamic product (the script will add/overwrite the product type as `.dynamic`).

## Example:
### .github/workflows/create-release.yml

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
- **target**: The target name you want to create an XCFramework for.
- **zip-version**: The version number to append to the name of the zip file.
- **output-path**: A path where to save the output files locally for later usage.

## Contributing

Please read the [Contribution Guide](CONTRIBUTING.md) for details on how to contribute to this project.
