# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Overview

This is a comprehensive mental coaching platform for athletes (primarily soccer players) built as a multi-tier application with three main components:

1. **Flutter Mobile/Web App** (`mental-coach-flutter/`) - Player-facing application
2. **React Admin Panel** (`mental-coach-admin/`) - Management interface for coaches/admins  
3. **Node.js API Server** (`mental-coach-api/`) - Backend services and API

All components integrate with Firebase for authentication, MongoDB for data persistence, and various third-party services (Twilio for SMS, SendGrid for email).

## Development Commands

### Quick Start (All Systems)
```bash
# Complete setup and run all systems
./scripts/quick-start.sh

# Run all systems in parallel (after initial setup)
./scripts/run-all.sh

# Run with iOS simulator (macOS only)
./scripts/run-simulator.sh
```

### Flutter App (`mental-coach-flutter/`)
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

### API Server (`mental-coach-api/`)
```bash
# Development server with auto-reload
npm run dev

# Fresh development start (kills existing port process)
npm run dev:fresh

# Production build
npm run build && npm start

# Management scripts
npm run create-user          # Interactive user creation
npm run make-user-admin      # Promote user to admin
npm run seed-training        # Populate training content
npm run reset-matches        # Clean match data
npm run test-otp            # Test SMS/OTP system
```

### Admin Panel (`mental-coach-admin/`)
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

## Architecture & Data Flow

### Authentication System
- **Primary**: Firebase Authentication with custom token validation
- **SMS/OTP**: Twilio integration for phone number verification
- **Google OAuth**: Integrated via Firebase Auth
- **Admin Role Management**: Role-based access control with Firebase claims

The system uses a sophisticated auth method management where each user has `allowedAuthMethods` defining which authentication methods they can use (email, SMS, Google).

### Environment Configuration (Flutter)
Flutter uses compile-time environment variables via `--dart-define`:
- `FLUTTER_ENV`: Environment type (dev/test/prod/local)
- `API_URL`: Backend API endpoint
- Firebase configuration variables for web builds

The `EnvironmentConfig` class automatically detects environment and adjusts API endpoints accordingly.

### Data Models (API)
Core MongoDB collections:
- **Users**: Player/coach accounts with authentication preferences
- **Training Programs**: Hierarchical course structure
- **Lessons**: Individual training content with video/exercise support
- **Matches/Leagues/Teams**: Sports management entities
- **User Progress**: Track completion and advancement

### State Management (Flutter)
- **Provider pattern**: User state, training data, app-wide state
- **Persistent storage**: SharedPreferences for user preferences
- **Deep linking**: Custom URL handling for match invitations and content sharing

### Admin Panel Architecture (React)
- **Material-UI**: Component library with RTL support for Hebrew
- **SWR**: Data fetching with caching and revalidation
- **React Hook Form**: Form validation and management with Yup schemas
- **Firebase Storage**: File upload for lesson thumbnails and media
- **Drag & Drop**: Reorderable lesson lists using @dnd-kit

## Docker & Deployment

All three projects are containerized and deploy-ready for Railway/similar platforms:

### Flutter Docker Build Arguments
```dockerfile
ARG FLUTTER_ENV=docker
ARG API_URL=http://localhost:3000/api
ARG FIREBASE_WEB_API_KEY=""
# ... other Firebase config variables
```

### Railway Configuration
Each project includes `railway.json` for automated deployment with health checks and environment variable support.

## Key Development Patterns

### API Error Handling
- Global error handler with structured responses
- `AppError` class for consistent error creation
- `catchAsync` wrapper for async route handlers
- Mongoose validation with custom error formatting

### Flutter State Patterns
- `EnvironmentConfig` singleton for runtime configuration
- Provider pattern for cross-widget state management
- Custom routing with go_router for deep linking support

### Admin Panel Patterns
- Custom hooks for dialog management (`useDialog`)
- Reusable form components with validation
- Data fetching patterns with loading states and error handling

## Important Configuration Files

### Environment Files Required
- `mental-coach-api/.env` - API server configuration (MongoDB, Firebase, Twilio, SendGrid)
- `mental-coach-admin/.env` - Admin panel config (Firebase, API endpoint)
- Flutter uses build-time variables (no .env file)

### Firebase Configuration
- `firebase_options.dart` (Flutter) - Generated Firebase config
- Firebase service account JSON for API server
- Firebase web config for admin panel

### Critical Scripts Location
- `mental-coach-api/scripts/` - Management utilities (user creation, seeding, cleanup)
- Root `/scripts/` - System-wide utilities (startup, IP detection)

## Testing & Development Workflow

### Local Development Setup
1. MongoDB running locally or Atlas connection
2. Firebase project with Authentication and Storage enabled
3. Twilio account for SMS testing (optional)
4. All `.env` files configured from `.env.example` templates

### Common Development Tasks
- Use management scripts in API for user setup and data seeding
- Test SMS flows with `npm run test-otp` in API project
- Use admin panel for content creation and user management
- Flutter supports hot reload for rapid UI development

### Database Seeding
The API includes comprehensive seeding scripts:
- `seed-training` - Sample training content for development
- `seed:real-training` - Production training programs
- Various cleanup scripts for development resets

## Multi-Language Support

- **Flutter**: Full RTL support for Hebrew with English fallbacks
- **Admin Panel**: Material-UI with RTL theme and Hebrew localization
- **API**: Hebrew error messages and email templates

## External Service Integration

### Required Services
- **MongoDB**: Primary data storage
- **Firebase**: Authentication, file storage, push notifications
- **Twilio**: SMS/OTP functionality
- **SendGrid**: Email notifications (React Email templates)

### Optional Services
- **Redis**: Caching layer (configured but optional)
- **App Check**: Firebase security for production builds