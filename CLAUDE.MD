# ProspectPro - Claude AI Context Guide

## Project Overview

ProspectPro is a **Verified Business Intelligence Platform** that provides professional contact discovery and enrichment with a strict zero fake data policy. The platform sources verified business contacts through Apollo API, professional licensing databases, and chamber of commerce directories.

**Version**: 4.1.0
**Author**: Alex Torelli
**Repository**: https://github.com/Alextorelli/ProspectPro

## Core Principles

1. **Zero Fake Data**: All contacts must be verified through authoritative sources
2. **Verification-First**: Every data point is tracked with verification status
3. **Budget-Conscious**: API usage is monitored and controlled
4. **Edge-First Architecture**: Backend operations run on Supabase Edge Functions
5. **Static Frontend**: HTML/JS hosted on CDN for optimal performance

## Architecture

### Frontend (`app/frontend/`)
- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **State Management**: Zustand
- **Routing**: React Router v6
- **Data Fetching**: TanStack Query (React Query)
- **Deployment**: Static hosting on Vercel

### Backend (`app/backend/`)
- **Runtime**: Supabase Edge Functions (Deno)
- **Database**: Supabase PostgreSQL with RLS (Row Level Security)
- **Authentication**: Supabase Auth
- **Key Functions**:
  - `business-discovery-background` - Async business discovery
  - `enrichment-orchestrator` - Contact enrichment coordination
  - `enrichment-hunter` - Hunter.io integration
  - `enrichment-neverbounce` - Email verification
  - `enrichment-business-license` - Professional licensing lookup
  - `campaign-export-user-aware` - Campaign data export

### Data Sources
- **Apollo API**: Professional contact data
- **Google Places API**: Business discovery
- **Foursquare Places**: Alternative business data
- **Hunter.io**: Email discovery and verification
- **NeverBounce**: Email validation
- **Professional Licensing APIs**: Verified credentials
- **Chamber of Commerce**: Local business directories

## Technology Stack

### Core Dependencies
- React 18 + React DOM
- TypeScript 5.9
- Supabase JS Client 2.39
- TanStack React Query 5.17
- React Router DOM 6.20
- Zustand (state management)
- Tailwind CSS + clsx + tailwind-merge
- Lucide React (icons)
- Recharts (data visualization)

### Development Tools
- Vite 7.1 (build tool)
- Vitest 3.2 (testing framework)
- Playwright (E2E testing)
- ESLint + TypeScript ESLint
- Supabase CLI 2.54
- Vercel CLI 48.6
- Mermaid CLI (documentation diagrams)

### Additional Tooling
- Model Context Protocol (MCP) servers
- React DevTools
- Highlight.run (observability)
- Pinecone (vector database)
- Drizzle ORM

## Project Structure

```
ProspectPro/
├── app/
│   ├── frontend/           # React application
│   │   ├── components/     # UI components
│   │   ├── pages/          # Route pages
│   │   ├── hooks/          # Custom React hooks
│   │   ├── store/          # Zustand stores
│   │   └── types/          # TypeScript types
│   ├── backend/            # Supabase Edge Functions
│   │   ├── functions/      # Edge function implementations
│   │   ├── schema/         # Database schemas
│   │   └── supabase/       # Supabase configuration
│   └── tests/              # Application tests
├── dev-tools/              # Development utilities
│   ├── agents/             # AI agent configurations
│   ├── scripts/            # Automation scripts
│   └── workspace/          # Workspace context files
├── docs/                   # Documentation
│   ├── app/                # Application docs
│   ├── dev-tools/          # Developer guides
│   ├── integration/        # Integration docs
│   ├── mmd-shared/         # Mermaid diagram configs
│   └── technical/          # Technical references
├── integration/            # Platform integration
│   ├── platform/           # Platform-specific configs
│   ├── infrastructure/     # Infrastructure scripts
│   └── monitoring/         # Observability tools
├── config/                 # Build configurations
└── tests/                  # Root-level tests
```

## Common Development Workflows

### Starting Development
```bash
npm run dev                          # Start Vite dev server
npm run dev:supabase                 # Start Edge Functions locally
npm run edge:serve                   # Serve specific Edge Function
```

### Testing
```bash
npm test                             # Run Vitest unit tests
npm run test:edge-functions          # Test Edge Functions
npm run test:deno                    # Run Deno tests
npx playwright test                  # Run E2E tests
```

### Building & Deployment
```bash
npm run build                        # Build frontend
npm run type-check                   # TypeScript validation
npm run lint                         # Lint codebase
npm run deploy:functions             # Deploy all Edge Functions
npm run deploy:vercel                # Deploy to Vercel
```

### Database Operations
```bash
npm run supabase:link                # Link to Supabase project
npm run supabase:status              # Check database status
npm run supabase:types               # Generate TypeScript types
npm run supabase:migrations:list     # List migrations
npm run supabase:db:push             # Push migrations to remote
```

### Documentation
```bash
npm run docs:generate                # Generate Mermaid diagrams
npm run docs:validate                # Validate documentation
npm run docs:fix                     # Auto-fix diagram issues
npm run system:reference             # Generate system reference
```

## Critical Files & Locations

### Configuration Files
- `package.json` - Project dependencies and scripts
- `vite.config.ts` - Vite build configuration
- `tsconfig.json` - TypeScript configuration (in `config/`)
- `.eslintrc.cjs` - ESLint rules
- `playwright.config.ts` - E2E test configuration
- `Taskfile.yml` - Task automation

### Authentication & Security
- `app/backend/functions/_shared/edge-auth.ts` - Edge Function auth
- `app/backend/functions/_shared/vault-client.ts` - Secrets management
- Row Level Security (RLS) policies enforced at database level

### Key Backend Services
- `app/backend/functions/_shared/api-usage.ts` - API usage tracking
- `app/backend/functions/_shared/cache-manager.ts` - Caching layer
- `app/backend/functions/_shared/cobalt-cache.ts` - Cobalt integration

### Important Documentation
- `docs/technical/SYSTEM_REFERENCE.md` - System architecture guide
- `docs/technical/CODEBASE_INDEX.md` - Code organization
- `CHANGELOG.md` - Version history
- `SUPABASE_MIGRATION.md` - Database migration guide

## Development Guidelines

### Code Style
- Use TypeScript for all new code
- Follow ESLint rules (max 0 warnings)
- Prefer functional components with hooks
- Use Tailwind utility classes for styling
- Implement proper error handling at system boundaries

### Testing Requirements
- Unit tests for business logic (Vitest)
- Integration tests for Edge Functions (Deno)
- E2E tests for critical user flows (Playwright)
- All tests must pass before deployment

### Security Best Practices
- Never commit secrets (use Supabase Vault)
- Enforce RLS on all database tables
- Validate user input at Edge Function boundaries
- Use `--no-verify-jwt` only for background functions
- Implement proper CORS policies

### Data Quality
- Verify all contact data sources
- Track verification status in database
- Reject fake or placeholder data
- Implement data quality scoring
- Cache verified results

## Environment Setup

### Required Tools
- Node.js 20.x
- Vercel CLI (`npm install -g vercel`)
- Supabase CLI (install via official script)
- GitHub CLI (for PR/issue management)
- Deno (for Edge Functions testing)

### Environment Variables
Key variables (see `.env.example` for full list):
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Public anonymous key
- `VITE_SUPABASE_URL` - Frontend Supabase URL
- API keys for Hunter.io, Apollo, Google Places, etc.

### Getting Started
1. Clone the repository
2. Install dependencies: `npm install`
3. Copy `.env.example` to `.env.local`
4. Link Supabase project: `npm run supabase:link`
5. Pull environment variables: `npm run env:pull`
6. Start development: `npm run dev`

## Common Issues & Solutions

### Supabase CLI Authentication
If CLI commands fail with auth errors:
```bash
npm run supabase:auth
npm run supabase:link
```

### Edge Function Deployment Failures
- Check Supabase CLI version: `supabase --version`
- Verify project link: `npm run supabase:status`
- Review function logs: `npm run edge:logs`

### Build Failures
- Clear cache: `npm run clean && npm install`
- Check TypeScript errors: `npm run type-check`
- Verify ESLint: `npm run lint`

### Test Failures
- Ensure local Edge Functions are running
- Check test environment variables
- Review error logs in `npm run edge:logs`

## MCP (Model Context Protocol) Integration

ProspectPro includes MCP server implementations for AI agent integration:

```bash
npm run mcp:install                  # Install MCP dependencies
npm run mcp:test                     # Test MCP servers
npm run mcp:dev                      # Start in development mode
npm run mcp:prod                     # Start in production mode
```

Located in `mcp-servers/` directory with dedicated configurations.

## Git Workflow

### Branch Strategy
- Main branch: production-ready code
- Feature branches: `claude/*` prefix for AI-assisted development
- All changes require testing before merge

### Commit Guidelines
- Use conventional commit messages
- Reference issue numbers when applicable
- Run tests before committing
- Ensure linting passes

### Creating Pull Requests
```bash
npm run lint                         # Ensure code quality
npm test                             # Run tests
npx playwright test                  # Run E2E tests
gh pr create --title "..." --body "..." # Create PR via GitHub CLI
```

## Additional Resources

- **Technical Reference**: `docs/technical/SYSTEM_REFERENCE.md`
- **Runbooks**: `docs/app/runbooks/APP_runbooks.md`
- **Development Guide**: `docs/dev-tools/DEV_README.md`
- **Integration Guide**: `docs/integration/INT_README.md`
- **Migration Guide**: `SUPABASE_MIGRATION.md`

## Key Contacts & Links

- **Supabase Project**: sriycekxdqnesdsgwiuc.supabase.co
- **Production URL**: prospectpro.appsmithery.co
- **Staging URL**: staging.prospectpro.appsmithery.co
- **Issue Tracker**: GitHub Issues
- **License**: MIT

---

*Last Updated: 2026-01-16*
*This guide is maintained for AI assistants working with the ProspectPro codebase.*
