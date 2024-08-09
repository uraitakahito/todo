#!/bin/bash
#
# Install Visual Studio Code Go extensions
#
extensions=(
  # https://marketplace.visualstudio.com/items?itemName=GitHub.copilot
  "GitHub.copilot"
  # https://marketplace.visualstudio.com/items?itemName=golang.Go
  "golang.Go"
)
for extension in ${extensions[@]}; do
  code --install-extension $extension
done
