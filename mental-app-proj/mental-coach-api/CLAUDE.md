# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Core Development
- `npm run dev` - Start development server with nodemon and ts-node
- `npm run dev:fresh` - Kill existing process on port and start fresh dev server
- `npm run build` - Compile TypeScript to JavaScript (outputs to `dist/`)
- `npm start` - Run production server from compiled files
- `npm run kill-port` - Kill process running on configured port

### Management Scripts
- `npm run create-user` - Interactive script to create new users
- `npm run make-user-admin` - Promote user to admin privileges
- `npm run app-token-generator` - Generate application tokens
- `npm run reset-matches` - Clean user match data
- `npm run reset-profile-marks` - Reset user profile progression stages
- `npm run seed-training` - Seed training content and programs

## Architecture Overview

### Tech Stack
- **Runtime**: Node.js with TypeScript
- **Framework**: Express.js with extensive middleware stack
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: Firebase Admin SDK
- **Email**: SendGrid with React Email templates
- **Security**: Helmet, CORS, rate limiting, input sanitization

### Core Structure
The application follows a layered MVC architecture:

- **Routes** (`/routes/`) - API endpoint definitions and middleware chaining
- **Controllers** (`/controllers/`) - Business logic and request handling
- **Models** (`/models/`) - Mongoose schemas and database interactions
- **Middlewares** (`/middlewares/`) - Authentication, validation, and request processing
- **Utils** (`/utils/`) - Shared utilities and helper functions

### Key Features
1. **Sports Mental Coaching Platform** - Primary focus on mental training for athletes
2. **Digital Training System** - Structured courses with lessons, exercises, and progress tracking
3. **Multi-tenant Architecture** - Supports leagues, teams, matches, and user management
4. **Firebase Integration** - Uses Firebase for authentication and real-time features
5. **Email System** - React-based email templates with SendGrid delivery

### Authentication System
- Uses Firebase Admin SDK for token verification
- `appAuthMiddleware.ts` - General authentication middleware
- `trainingAuthMiddleware.ts` - Specialized auth for training content
- Role-based access control with admin privileges

### Database Models
- **Users** - Core user management with mental training progress tracking
- **Training Programs** - Course structure with lessons and exercises
- **Matches/Leagues/Teams** - Sports-related entities
- **Subscriptions** - User subscription and access control

### API Structure
All endpoints are prefixed with `/api/` and organized by domain:
- `/api/users` - User management
- `/api/training-programs` - Digital course system
- `/api/lessons` - Individual lesson management
- `/api/exercises` - Training exercises and assessments
- `/api/user` - User progress and enrollment
- `/api/matches`, `/api/leagues`, `/api/teams` - Sports entities
- `/api/auth` - Authentication endpoints

### Environment Requirements
Create `.env` file with:
```
PORT=5001
NODE_ENV=development
MONGO_URI_DEV=mongodb://localhost:27017/
DB_NAME=mental-coach
SENDGRID_API_KEY=your_sendgrid_key
```

### Development Notes
- Server runs on port 3000 by default (or PORT env var)
- Extensive logging middleware for request debugging
- CORS configured for development and specific production domains
- Rate limiting set to 1000 requests per window
- MongoDB sanitization and HPP protection enabled
- TypeScript compilation target: ESNext with CommonJS modules

### Error Handling
- Global error handler in `controllers/error-controller.ts`
- Custom `AppError` class for structured error responses
- `catchAsync` utility wrapper for async route handlers

### Scripts Location
Management scripts are in `/scripts/` directory and use ES modules (.mjs files)