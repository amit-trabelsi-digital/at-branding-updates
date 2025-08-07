# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Overview

Mental Coach is a comprehensive mental training platform for athletes (primarily soccer players) built as a microservices architecture with three main components:

1. **Flutter Mobile/Web App** (`mental-coach-flutter/`) - Player-facing application
2. **React Admin Panel** (`mental-coach-admin/`) - Management interface for coaches/admins  
3. **Node.js API Server** (`mental-coach-api/`) - Backend services and API

All components integrate with Firebase for authentication, MongoDB for data persistence, and various third-party services (Twilio for SMS, SendGrid for email).

## Version Management System

Mental Coach implements automatic version management following Semantic Versioning:

### Version Bumping Commands
```bash
# Automatic version bump based on commit message
npm run version:bump

# Manual version bumps
npm run version:patch    # Bug fixes (0.0.1)
npm run version:minor    # New features (0.1.0)
npm run version:major    # Breaking changes (1.0.0)
```

### Git Hooks Integration
```bash
# Install automatic version bumping on commits
./scripts/version/install-git-hooks.sh

# Version updates automatically based on commit messages:
# feat: new feature → MINOR version
# fix: bug fix → PATCH version  
# BREAKING CHANGE → MAJOR version
```

### Version Files Structure
- `version.json` - Central version information for each project
- API: Exposes version info via `/api/info/version` endpoint
- Admin: Version displayed in UI via `BUILD_INFO` constant
- Flutter: Version accessible via `VersionHelper.instance`

## Quick Start Commands

### Complete System Startup
```bash
# Full setup and run all systems
./scripts/development/quick-start.sh

# Run all systems in parallel (after initial setup)
./scripts/development/run-all.sh

# Run with iOS simulator (macOS only)  
./scripts/development/run-simulator.sh

# Get local IP for physical device testing
./scripts/utilities/get-local-ip.sh
```

### Individual System Commands

#### API Server (`mental-coach-api/`)
```bash
# Development with auto-reload
npm run dev

# Fresh start (kills port process first)
npm run dev:fresh

# Production build and start
npm run build && npm start

# Management scripts
npm run create-user          # Interactive user creation
npm run make-user-admin      # Promote user to admin
npm run seed-training        # Populate training content
npm run reset-matches        # Clean match data
npm run test-otp            # Test SMS/OTP system
```

#### Admin Panel (`mental-coach-admin/`)
```bash
# Development server
npm run dev

# Production build
npm run build

# Type checking
tsc -b

# Linting
npm run lint
```

#### Flutter App (`mental-coach-flutter/`)
```bash
# Local development with hot reload
flutter run -d chrome

# Build for web with environment variables
flutter build web --release --dart-define=FLUTTER_ENV=prod --dart-define=API_URL=https://api-url.com/api

# Run tests
flutter test

# Generate app icons
flutter pub run flutter_launcher_icons:main
```

## Architecture Patterns

### Microservices Communication
- **Data Flow**: Flutter/Admin → API Server → MongoDB
- **Authentication**: Firebase Auth → JWT tokens → API validation
- **Strict Separation**: Only API server accesses database directly

### Authentication System
- **Primary**: Firebase Authentication with custom token validation
- **SMS/OTP**: Twilio integration for phone verification
- **Multi-method**: Each user has `allowedAuthMethods` (email, SMS, Google)
- **Role-based**: Admin privileges managed via Firebase claims

### State Management
- **Flutter**: Provider pattern for global state, SharedPreferences for persistence
- **React**: SWR for data fetching with caching, React Hook Form for forms
- **API**: Express.js with middleware chains for validation and authentication

### Environment Configuration
- **Flutter**: Compile-time variables via `--dart-define` (FLUTTER_ENV, API_URL)
- **API**: `.env` file with MongoDB, Firebase, Twilio, SendGrid credentials
- **Admin**: `.env` file with Firebase config and API endpoint

## Core Data Models

### Primary Collections (MongoDB)
- **Users**: Player/coach accounts with authentication preferences and progress tracking
- **Training Programs**: Hierarchical course structure with lessons and exercises
- **Lessons**: Individual training content with video/exercise support and thumbnails
- **Matches/Leagues/Teams**: Sports management entities for competitive tracking
- **User Progress**: Completion tracking and advancement metrics

### Key Relationships
- Users → Training Programs (enrollment)
- Training Programs → Lessons (hierarchical content)
- Users → Matches (participation and scoring)
- Users → User Progress (individual tracking)

## Development Workflow

### Local Development Requirements
1. **MongoDB**: Local instance or Atlas connection
2. **Firebase Project**: Authentication and Storage enabled
3. **Node.js**: Version 18+ for API server
4. **Flutter SDK**: Version 3.6+ for mobile app
5. **Environment Files**: All `.env` files configured from examples

### Common Development Tasks
- Use API management scripts for user setup and data seeding
- Test SMS flows with `npm run test-otp` in API project
- Use admin panel for content creation and user management
- Flutter supports hot reload for rapid UI development
- All services can run in parallel for full-stack development

### Testing Strategy
- **API**: Management scripts for data seeding and user creation
- **Flutter**: Widget tests and integration tests via `flutter test`
- **Admin**: Type checking with TypeScript, linting with ESLint
- **SMS/OTP**: Dedicated test script for Twilio integration

## Docker & Deployment

### Container Architecture
All three projects are containerized with Railway deployment configuration:
- Individual `Dockerfile` per service
- `railway.json` for deployment settings
- Health checks and environment variable support
- Multi-stage builds for optimization

### Environment Variables Structure
- **API**: Database, Firebase Admin SDK, external service credentials
- **Admin**: Firebase client config, API endpoint URL
- **Flutter**: Build-time variables for environment and API URLs

## Key Technical Features

### Multi-language Support
- **Hebrew RTL**: Full right-to-left support across all interfaces
- **Material-UI**: RTL theme configuration in admin panel
- **Flutter**: Internationalization with Hebrew localization

### File Management
- **Firebase Storage**: Image uploads for lesson thumbnails
- **Drag & Drop**: Reorderable lesson lists using @dnd-kit
- **Video Support**: Vimeo integration with custom player

### Security Implementation
- **JWT Authentication**: Firebase tokens validated on API server
- **CORS Protection**: Configured for specific domains
- **Rate Limiting**: Request throttling on API endpoints
- **Input Sanitization**: MongoDB injection protection
- **Role-based Access**: Admin privileges with Firebase claims

### External Service Integration
- **Firebase**: Auth, Storage, App Check, Push Notifications
- **Twilio**: SMS/OTP for phone verification
- **SendGrid**: Email notifications with React Email templates
- **MongoDB Atlas**: Primary data storage with connection pooling

## Troubleshooting Guide

### Port Management
- **API Server**: Port 3000 (configurable via PORT env var)
- **Admin Panel**: Port 5173 (Vite default)
- **Flutter Web**: Port varies (auto-assigned)
- Use `npm run kill-port` in API to clear stuck processes

### Common Issues
- **MongoDB Connection**: Verify connection string in API .env file
- **Firebase Config**: Ensure all Firebase keys are properly set
- **SMS Testing**: Use test-otp script to verify Twilio integration
- **Build Failures**: Check TypeScript compilation and dependency versions

### Version Information Access

#### API Server
```javascript
// Version endpoint returns full build info
GET /api/info/version
// Response includes: version, build, buildDate, description
```

#### Admin Panel  
```typescript
import { BUILD_INFO, ADMIN_VERSION } from '@/utils/version';

console.log(`Version: ${BUILD_INFO.version}`);
console.log(`Build: ${BUILD_INFO.build}`);
```

#### Flutter App
```dart
import 'package:mental_coach/utils/version_helper.dart';

// Initialize once in main()
await VersionHelper.instance.initialize();

// Access version info
String version = VersionHelper.instance.version;
String fullVersion = VersionHelper.instance.fullVersion; // "0.9.1+14"
Map<String, String> info = VersionHelper.instance.versionInfo;
```

### Deployment Checklist
1. Environment variables configured for target environment
2. Firebase project settings match deployment URLs
3. MongoDB connection string points to production database
4. External service credentials (Twilio, SendGrid) are production-ready
5. CORS settings allow production domain origins
6. Version information properly displayed in all interfaces