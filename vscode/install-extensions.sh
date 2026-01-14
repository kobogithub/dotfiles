#!/bin/bash
# VS Code extensions installer script

# Essential extensions
ESSENTIAL_EXTENSIONS=(
    # Language support
    "ms-python.python"                      # Python
    "ms-vscode.vscode-typescript-next"      # TypeScript
    "bradlc.vscode-tailwindcss"            # Tailwind CSS
    "ms-vscode.vscode-json"                # JSON
    
    # Frameworks
    "ms-vscode.vscode-eslint"              # ESLint
    "esbenp.prettier-vscode"               # Prettier
    "ms-vscode.vscode-react-native"        # React Native
    "Vue.volar"                            # Vue.js
    
    # Docker & Kubernetes
    "ms-azuretools.vscode-docker"          # Docker
    "ms-kubernetes-tools.vscode-kubernetes-tools"  # Kubernetes
    
    # Git
    "eamodio.gitlens"                      # GitLens
    "github.vscode-github-actions"         # GitHub Actions
    
    # Themes & Icons
    "pkief.material-icon-theme"           # Material Icon Theme
    "github.github-vscode-theme"          # GitHub Theme
    
    # Productivity
    "streetsidesoftware.code-spell-checker" # Spell Checker
    "ms-vscode-remote.remote-ssh"         # Remote SSH
    "ms-vscode.remote-explorer"           # Remote Explorer
    "christian-kohler.path-intellisense"  # Path Intellisense
    "formulahendry.auto-rename-tag"       # Auto Rename Tag
    "ms-vscode.vscode-todo-highlight"     # TODO Highlight
)

# Development extensions
DEVELOPMENT_EXTENSIONS=(
    # Testing
    "ms-python.pytest"                    # Pytest
    "ms-vscode.test-adapter-converter"    # Test Explorer
    
    # Linting & Formatting
    "ms-python.black-formatter"          # Black Formatter
    "ms-python.flake8"                   # Flake8
    "ms-python.mypy-type-checker"        # MyPy
    
    # Databases
    "mtxr.sqltools"                       # SQL Tools
    "ms-mssql.mssql"                      # SQL Server
    
    # API Development
    "humao.rest-client"                   # REST Client
    
    # Markdown
    "yzhang.markdown-all-in-one"         # Markdown All in One
    "shd101wyy.markdown-preview-enhanced" # Markdown Preview Enhanced
)

# Optional extensions
OPTIONAL_EXTENSIONS=(
    # AI/Copilot
    "github.copilot"                      # GitHub Copilot
    "github.copilot-chat"                 # GitHub Copilot Chat
    
    # Advanced tools
    "ms-vscode.hexeditor"                 # Hex Editor
    "redhat.vscode-yaml"                  # YAML
    "ms-dotnettools.vscode-dotnet-runtime" # .NET Runtime
    "rust-lang.rust-analyzer"            # Rust
    "golang.go"                           # Go
)

install_extensions() {
    local extensions=("$@")
    echo "Installing VS Code extensions..."
    
    for ext in "${extensions[@]}"; do
        echo "Installing: $ext"
        code --install-extension "$ext" --force
    done
}

install_essential() {
    echo "Installing essential VS Code extensions..."
    install_extensions "${ESSENTIAL_EXTENSIONS[@]}"
}

install_development() {
    echo "Installing development VS Code extensions..."
    install_extensions "${DEVELOPMENT_EXTENSIONS[@]}"
}

install_optional() {
    echo "Installing optional VS Code extensions..."
    install_extensions "${OPTIONAL_EXTENSIONS[@]}"
}

install_all() {
    echo "Installing all VS Code extensions..."
    install_extensions "${ESSENTIAL_EXTENSIONS[@]}" "${DEVELOPMENT_EXTENSIONS[@]}" "${OPTIONAL_EXTENSIONS[@]}"
}

list_extensions() {
    echo "=== Essential Extensions ==="
    printf '%s\n' "${ESSENTIAL_EXTENSIONS[@]}"
    echo ""
    echo "=== Development Extensions ==="
    printf '%s\n' "${DEVELOPMENT_EXTENSIONS[@]}"
    echo ""
    echo "=== Optional Extensions ==="
    printf '%s\n' "${OPTIONAL_EXTENSIONS[@]}"
}

# Check if VS Code is installed
if ! command -v code >/dev/null 2>&1; then
    echo "VS Code is not installed or not in PATH"
    echo "Install VS Code first: https://code.visualstudio.com/"
    exit 1
fi

# Handle command line arguments
case "${1:-essential}" in
    "essential"|"")
        install_essential
        ;;
    "development"|"dev")
        install_development
        ;;
    "optional"|"opt")
        install_optional
        ;;
    "all")
        install_all
        ;;
    "list")
        list_extensions
        ;;
    *)
        echo "Usage: $0 [essential|development|optional|all|list]"
        echo ""
        echo "Commands:"
        echo "  essential    - Install essential extensions (default)"
        echo "  development  - Install development extensions"
        echo "  optional     - Install optional extensions"
        echo "  all          - Install all extensions"
        echo "  list         - List all available extensions"
        exit 1
        ;;
esac

echo "VS Code extensions installation complete!"
echo "Restart VS Code to activate all extensions."