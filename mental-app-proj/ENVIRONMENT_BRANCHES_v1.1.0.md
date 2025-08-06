# Environment-Specific Branches for v1.1.0

## Created Branches

### 1. test-v1.1.0
- **Purpose**: Testing environment configuration
- **Created from**: main branch
- **Pushed to**: origin/test-v1.1.0
- **Environment files created**:
  - `.env.test` - Main test environment configuration
  - `mental-coach-api/.env.test` - API test configuration
  - `mental-coach-admin/.env.test` - Admin panel test configuration
  - `mental-coach-flutter/lib/firebase_options_test.dart` - Flutter test Firebase config
  - `setup-test-env.sh` - Setup script for test environment

### 2. dev-v1.1.0
- **Purpose**: Development environment configuration  
- **Created from**: main branch
- **Pushed to**: origin/dev-v1.1.0
- **Environment files created**:
  - `.env.dev` - Main dev environment configuration
  - `mental-coach-api/.env.dev` - API dev configuration
  - `mental-coach-admin/.env.dev` - Admin panel dev configuration
  - `mental-coach-flutter/lib/firebase_options_dev.dart` - Flutter dev Firebase config
  - `setup-dev-env.sh` - Setup script for dev environment

## Key Configuration Differences

### Test Environment (test-v1.1.0)
- Port: 3001 (API)
- Database: mental-coach-test
- Features: Debug mode enabled, mock services enabled
- Firebase Project: mental-coach-test

### Dev Environment (dev-v1.1.0)
- Port: 3000 (API)
- Database: mental-coach-dev
- Features: Hot reload, Swagger docs, dev tools enabled
- Firebase Project: mental-coach-dev

## Next Steps

Since the submodules appear to be separate git repositories, you'll need to:

1. **For each submodule (mental-coach-api, mental-coach-admin, mental-coach-flutter)**:
   - Navigate to the submodule directory
   - Create appropriate branches (test-v1.1.0 and dev-v1.1.0)
   - Copy the respective environment files
   - Commit and push changes

2. **Update main project** to reference the correct submodule branches if needed

## Usage

To switch between environments:

```bash
# For test environment
git checkout test-v1.1.0
./setup-test-env.sh

# For dev environment  
git checkout dev-v1.1.0
./setup-dev-env.sh
```

## Important Notes

- Replace placeholder Firebase credentials with actual project credentials
- Update API keys (SendGrid, Twilio, etc.) with real test/dev keys
- Ensure MongoDB instances are set up for each environment
- Keep production credentials separate and secure
