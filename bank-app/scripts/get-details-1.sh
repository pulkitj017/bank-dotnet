#!/bin/bash
dotnet tool install --global dotnet-outdated-tool --add-source https://api.nuget.org/v3/index.json
# Check for outdated .NET dependencies and save the output to a file
dotnet outdated > outdated-dependencies.txt

# Install dotnet-project-licenses tool globally
dotnet tool install --global dotnet-project-licenses
echo $HOME/.dotnet/tools/dotnet-project-licenses

# Ensure the tool is in your PATH (optional: add $HOME/.dotnet/tools to PATH if not already)
export PATH="$PATH:$HOME/.dotnet/tools"

# List installed global tools to verify installation
dotnet tool list -g

# Path to the project directory or specific .csproj/.fsproj file
PROJECT_PATH="./"

# Run dotnet-project-licenses to generate a licenses report including transitive dependencies
$HOME/.dotnet/tools/dotnet-project-licenses -i "$PROJECT_PATH" --include-transitive > licenses.txt

