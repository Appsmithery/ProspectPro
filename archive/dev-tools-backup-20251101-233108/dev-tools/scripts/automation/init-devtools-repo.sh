#!/usr/bin/env bash
# dev-tools/scripts/automation/init-devtools-repo.sh
#
# Initializes the Dev-Tools repository skeleton with base files

set -euo pipefail

DEV_TOOLS_ROOT="${1:?Please provide Dev-Tools repository path}"
DRY_RUN="${2:-false}"

if [ "$DRY_RUN" = "true" ]; then
  echo "=== DRY RUN MODE - No files will be created ==="
fi

echo "=== Initializing Dev-Tools Repository Skeleton ==="
echo "Target: $DEV_TOOLS_ROOT"
echo ""

# Create directory if it doesn't exist
if [ ! -d "$DEV_TOOLS_ROOT" ]; then
  echo "Creating target directory..."
  if [ "$DRY_RUN" = "false" ]; then
    mkdir -p "$DEV_TOOLS_ROOT"
  fi
fi

cd "$DEV_TOOLS_ROOT"

# Initialize git if not already done
if [ ! -d ".git" ] && [ "$DRY_RUN" = "false" ]; then
  echo "1. Initializing git repository..."
  git init
  git checkout -b prospect-pro-tools 2>/dev/null || git checkout prospect-pro-tools
else
  echo "1. Git repository already initialized"
fi

# Create .gitignore
echo ""
echo "2. Creating .gitignore..."
if [ "$DRY_RUN" = "false" ]; then
  cat > .gitignore << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build outputs
dist/
build/
*.tsbuildinfo

# Testing
coverage/
.nyc_output/
*.log

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/settings.json
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Temporary
*.tmp
.temp/
.cache/

# Deno
.deno_lsp/
EOF
else
  echo "  [DRY RUN] Would create .gitignore"
fi

# Create package.json
echo ""
echo "3. Creating package.json..."
if [ "$DRY_RUN" = "false" ]; then
  cat > package.json << 'EOF'
{
  "name": "@prospectpro/dev-tools",
  "version": "1.0.0",
  "description": "Portable development tooling, agent workflows, and test infrastructure extracted from ProspectPro",
  "type": "module",
  "keywords": [
    "development-tools",
    "agents",
    "mcp",
    "testing",
    "automation"
  ],
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/Alextorelli/Dev-Tools.git"
  },
  "workspaces": [
    "agents/client-service-layer",
    "agents/mcp-servers/utility"
  ],
  "exports": {
    "./agents/*": "./agents/*/config.json",
    "./testing/*": "./testing/*",
    "./scripts/*": "./scripts/*"
  },
  "scripts": {
    "build": "npm run build --workspaces --if-present",
    "test": "vitest run",
    "test:watch": "vitest watch",
    "test:agents": "vitest run --config testing/configs/vitest.agents.config.ts",
    "lint": "eslint . --ext .ts,.js,.tsx,.jsx",
    "validate": "npm run lint && npm run test",
    "prepare": "npm run build"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "eslint": "^8.0.0",
    "typescript": "^5.0.0",
    "vitest": "^1.0.0",
    "playwright": "^1.40.0"
  }
}
EOF
else
  echo "  [DRY RUN] Would create package.json"
fi

# Create tsconfig.json
echo ""
echo "4. Creating tsconfig.json..."
if [ "$DRY_RUN" = "false" ]; then
  cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022"],
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "strict": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist",
    "rootDir": "./",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "paths": {
      "@agents/*": ["./agents/*"],
      "@testing/*": ["./testing/*"],
      "@scripts/*": ["./scripts/*"]
    }
  },
  "include": [
    "agents/**/*",
    "testing/**/*",
    "scripts/**/*",
    "automation/**/*"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "**/*.test.ts",
    "**/*.spec.ts"
  ]
}
EOF
else
  echo "  [DRY RUN] Would create tsconfig.json"
fi

# Create README.md
echo ""
echo "5. Creating README.md..."
if [ "$DRY_RUN" = "false" ]; then
  cat > README.md << 'EOF'
# ProspectPro Dev-Tools

Portable development tooling, agent workflows, and test infrastructure extracted from ProspectPro.

## Features

- **Agent Profiles**: Portable AI agent configurations for development, observability, production ops, and system architecture
- **MCP Servers**: Model Context Protocol servers for extended agent capabilities
- **Testing Infrastructure**: Vitest and Playwright configurations with agent test suites
- **Automation Scripts**: CI/CD, setup, and validation automation
- **Context Management**: Agent context store and session management

## Installation

### As npm Package

```bash
npm install @prospectpro/dev-tools
```

### As Git Submodule

```bash
git submodule add https://github.com/Alextorelli/Dev-Tools.git dev-tools-package
git submodule update --init --recursive
```

## Quick Start

### Using Agent Profiles

Agent profiles are located in `agents/` and include:
- `_development-workflow`: Development workflow automation
- `_observability`: System monitoring and telemetry
- `_production-ops`: Deployment and operations
- `_system-architect`: Architecture and design

Each agent has:
- `config.json`: Agent configuration
- `instructions.md`: Agent instructions and context
- `toolset.jsonc`: Available tools and MCP servers
- `taskfile.yaml`: Task automation

### Running Tests

```bash
# Run all tests
npm test

# Run agent tests
npm run test:agents

# Watch mode
npm run test:watch
```

### Building MCP Servers

```bash
# Build all workspaces
npm run build

# Build specific MCP server
npm run build --workspace agents/mcp-servers/utility
```

## Integration Guide

### Integrating into Your Project

1. Add as git submodule or npm dependency
2. Update your Taskfile.yml to reference dev-tools tasks
3. Configure your .vscode/settings.json to use MCP servers
4. Copy agent profiles to your .github/agents/ directory
5. Update import paths in your scripts

### Example Integration

```yaml
# Taskfile.yml
agents:test:
  cmds:
    - task: -d dev-tools-package/ agents:test:full
```

## Documentation

- [Agent Profiles](docs/agents/README.md)
- [MCP Servers](docs/mcp/README.md)
- [Testing Guide](docs/testing/README.md)
- [Automation Scripts](docs/automation/README.md)

## License

MIT

## Extracted From

This package was extracted from the [ProspectPro](https://github.com/Appsmithery/ProspectPro) repository as part of a repository restructure to create reusable, portable development tooling.

See `EXTRACTION_MANIFEST.md` for details on the extraction process.
EOF
else
  echo "  [DRY RUN] Would create README.md"
fi

# Create LICENSE (MIT)
echo ""
echo "6. Creating LICENSE..."
if [ "$DRY_RUN" = "false" ]; then
  cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2024 ProspectPro Development Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
else
  echo "  [DRY RUN] Would create LICENSE"
fi

# Create directory structure
echo ""
echo "7. Creating directory structure..."
if [ "$DRY_RUN" = "false" ]; then
  mkdir -p agents/{_development-workflow,_observability,_production-ops,_system-architect}
  mkdir -p agents/{client-service-layer,context,mcp-servers,scripts}
  mkdir -p automation/ci-cd
  mkdir -p testing/{agents,configs,utils}
  mkdir -p scripts/{automation,setup,tooling}
  mkdir -p workspace/context
  mkdir -p legacy
  mkdir -p docs/{agents,automation,testing,mcp}
  echo "  ✓ Directory structure created"
else
  echo "  [DRY RUN] Would create directory structure"
fi

if [ "$DRY_RUN" = "true" ]; then
  echo ""
  echo "=== DRY RUN COMPLETE - No files were created ==="
else
  echo ""
  echo "=== Dev-Tools Repository Skeleton Complete ==="
  echo ""
  echo "Next steps:"
  echo "1. Review generated files in $DEV_TOOLS_ROOT"
  echo "2. Run extraction scripts to populate repository"
  echo "3. Review and adjust package.json as needed"
  echo "4. Commit skeleton files before extraction"
fi
