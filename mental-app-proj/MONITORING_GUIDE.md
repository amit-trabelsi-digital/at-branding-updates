# Development Environment Monitoring & Housekeeping Guide

## Current Status

### Port Status (As of now)
- **Port 5000**: ✅ OPEN (Control Center using it)
- **Port 5173**: ❌ NOT IN USE (Vite admin panel not running)
- **Port 4000/8000**: ❌ NOT IN USE (Flutter web not running)

### Running Processes
- Flutter processes are currently suspended (state: T)
- No Node.js API server running
- No Vite development server running

## Quick Commands for Monitoring

### 1. Check Port Usage
```bash
# Check all important ports
lsof -i :5000 -i :5173 -i :4000 -i :8000 | grep LISTEN

# Or use the custom rule 'ports'
ports
```

### 2. Monitor Logs in Real-Time

#### API Server (Port 5000)
```bash
# In the API terminal, nodemon will auto-reload on file changes
# Watch the logs:
tail -f logs/api.log  # If logging is set up
# Or just watch the terminal output directly
```

#### Flutter App (Port varies)
```bash
# In the Flutter terminal:
# Hot reload: Press 'r' in the terminal
# Hot restart: Press 'R' in the terminal
# Debug console will show logs automatically
```

#### Admin Panel (Port 5173)
```bash
# Vite has built-in HMR (Hot Module Replacement)
# Changes will auto-refresh in the browser
# Watch the terminal for compilation errors
```

## Development Workflow

### Starting Services (Correct Order)
1. **Start API Server First**
   ```bash
   cd mental-coach-api
   npm run dev  # Uses nodemon for auto-reload
   ```

2. **Start Flutter App**
   ```bash
   cd mental-coach-flutter
   flutter run -d chrome  # For web
   # OR
   flutter run  # For mobile device/emulator
   ```

3. **Start Admin Panel**
   ```bash
   cd mental-coach-admin
   npm run dev  # Vite with HMR
   ```

### During Development

#### API Development
- Nodemon watches for file changes in `.js`, `.json` files
- Automatically restarts server on changes
- Check terminal for restart messages

#### Flutter Development
- **Hot Reload (r)**: Preserves app state, updates UI
- **Hot Restart (R)**: Restarts app, loses state
- **q**: Quit the app
- **p**: Show widget inspector URL
- **o**: Toggle platform (iOS/Android look)

#### Admin Panel Development
- Vite HMR updates modules without full reload
- CSS changes are instant
- Component changes preserve state when possible
- Check browser console for HMR logs

### Monitoring Multiple Terminals

Use terminal tabs or splits:
```bash
# Terminal 1: API logs
cd mental-coach-api && npm run dev

# Terminal 2: Flutter logs
cd mental-coach-flutter && flutter run -d chrome

# Terminal 3: Admin panel logs
cd mental-coach-admin && npm run dev
```

## Stopping Services (Reverse Order)

### Graceful Shutdown
1. **Stop Admin Panel**: Ctrl+C in admin terminal
2. **Stop Flutter**: 'q' in Flutter terminal (or Ctrl+C)
3. **Stop API Server**: Ctrl+C in API terminal

### Force Stop (if needed)
```bash
# Find and kill specific processes
ps aux | grep node | grep 5000  # Find API server
ps aux | grep flutter           # Find Flutter processes
ps aux | grep vite              # Find Vite server

# Kill by PID
kill -9 [PID]

# Or kill all Node processes (careful!)
killall node
```

## Housekeeping Tasks

### 1. Clean Flutter Build
```bash
cd mental-coach-flutter
flutter clean
flutter pub get
```

### 2. Clear Node Modules (if needed)
```bash
# API
cd mental-coach-api
rm -rf node_modules package-lock.json
npm install

# Admin
cd mental-coach-admin
rm -rf node_modules package-lock.json
npm install
```

### 3. Clear Browser Cache
- Chrome: Cmd+Shift+R (hard refresh)
- Or: Open DevTools → Application → Clear Storage

### 4. Check Disk Space
```bash
# Check project sizes
du -sh mental-coach-*

# Clean unnecessary files
find . -name ".DS_Store" -delete
find . -name "*.log" -mtime +7 -delete  # Delete logs older than 7 days
```

### 5. Database Maintenance
```bash
# If using MongoDB locally
mongosh
> use mentalcoach
> db.stats()  # Check database size
> db.sessions.remove({})  # Clear old sessions if needed
```

## Troubleshooting

### Port Already in Use
```bash
# Find what's using a port
lsof -i :5000

# Kill the process
kill -9 [PID]
```

### Flutter Web Not Loading
```bash
# Clear Flutter web cache
flutter clean
rm -rf build/web
flutter build web
```

### API Not Responding
```bash
# Check if MongoDB is running
brew services list | grep mongodb

# Restart if needed
brew services restart mongodb-community
```

### Admin Panel Build Issues
```bash
# Clear Vite cache
cd mental-coach-admin
rm -rf node_modules/.vite
npm run dev
```

## Quick Health Check Script

Create a `check-health.sh`:
```bash
#!/bin/bash
echo "=== Checking Mental Coach Dev Environment ==="
echo ""
echo "📡 Port Status:"
lsof -i :5000 -i :5173 -i :4000 | grep LISTEN || echo "No services running"
echo ""
echo "🔄 Running Processes:"
ps aux | grep -E 'node.*mental|flutter|vite' | grep -v grep || echo "No processes found"
echo ""
echo "💾 Database Status:"
brew services list | grep mongodb || echo "MongoDB not installed via brew"
echo ""
echo "📦 Disk Usage:"
du -sh mental-coach-* 2>/dev/null || echo "Project directories not found"
```

Make it executable:
```bash
chmod +x check-health.sh
./check-health.sh
```

## VSCode/Cursor Integration

### Recommended Extensions
- Flutter
- Dart
- ESLint
- Prettier
- MongoDB for VS Code
- Thunder Client (API testing)

### Launch Configurations
Add to `.vscode/launch.json` for easy debugging:
```json
{
  "configurations": [
    {
      "name": "Flutter Web",
      "type": "dart",
      "request": "launch",
      "program": "mental-coach-flutter/lib/main.dart",
      "args": ["-d", "chrome"]
    },
    {
      "name": "API Server",
      "type": "node",
      "request": "launch",
      "cwd": "${workspaceFolder}/mental-coach-api",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"]
    }
  ]
}
```

## Notes
- Always check that all three services can communicate
- Monitor memory usage if running all services locally
- Use environment variables for API endpoints
- Keep terminals organized with clear labels
- Regular commits before major changes
