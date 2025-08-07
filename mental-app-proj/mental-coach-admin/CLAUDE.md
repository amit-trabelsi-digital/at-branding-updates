# CLAUDE.md - Mental Coach Admin Panel

## Recent Updates

### Image Upload for Lesson Thumbnails
- **Date**: 2025-01-30
- **Change**: Replaced URL input field for lesson thumbnails with file upload component
- **Files Modified**:
  - `src/components/general/ImageUpload.tsx` - New component for image uploads
  - `src/components/drawers/LessonEditDrawer.tsx` - Updated to use ImageUpload component
  - `src/services/firebaseStorage.ts` - Enhanced Firebase storage service

### Features Added:
1. **ImageUpload Component**:
   - Drag & drop file upload
   - Image preview with proper aspect ratio
   - File validation (type and size)
   - Progress indicator during upload
   - Remove image functionality
   - RTL support

2. **Firebase Storage Integration**:
   - Automatic file upload to Firebase Storage
   - Unique filename generation
   - Progress tracking
   - Error handling

3. **Lesson Thumbnail Management**:
   - Upload custom thumbnails for lessons
   - Automatic aspect ratio enforcement (16:9)
   - Preview before upload
   - Integration with existing lesson data structure

### Technical Details:
- Uses Firebase Storage for file hosting
- Supports JPG, PNG, GIF, WebP formats
- Maximum file size: 10MB
- Automatic filename sanitization
- Progress tracking with Material-UI components

### Usage:
In lesson edit drawer, users can now:
1. Upload custom thumbnail images
2. See preview of uploaded images
3. Remove existing thumbnails
4. Maintain existing URL-based thumbnails for backward compatibility

In training program management, users can now:
1. Drag and drop lessons to reorder them
2. See real-time visual feedback during drag operations
3. Automatically save new order to server
4. View lessons in a sortable table with drag handles

## Project Structure

This is a React + TypeScript admin panel for the Mental Coach application.

### Key Technologies:
- React 18 with TypeScript
- Material-UI (MUI) for components
- React Hook Form for form management
- SWR for data fetching
- Firebase for authentication and storage
- Vite for build tooling
- @dnd-kit/core for drag and drop functionality

### Main Features:
1. **User Management** - Create, edit, and manage users
2. **Training Programs** - Manage courses and lessons
3. **Exercises** - Create and manage training exercises
4. **Media Management** - Upload and manage files
5. **Analytics** - View user progress and statistics

### File Structure:
```
src/
├── components/
│   ├── general/          # Reusable components
│   │   ├── ImageUpload.tsx       # New image upload component
│   │   ├── ExercisesList.tsx     # Exercise display component
│   │   ├── SortableLessonsList.tsx # Drag & drop lessons list
│   │   └── ...
│   ├── drawers/          # Side drawer components
│   │   ├── LessonEditDrawer.tsx  # Lesson editing (updated)
│   │   └── ...
│   └── dialogs/          # Modal dialogs
├── services/
│   ├── firebaseStorage.ts       # Firebase storage utilities
│   ├── coursesApi.ts            # API calls for courses
│   └── fetch.ts                 # Base fetch wrapper
├── utils/
│   ├── firebase.ts              # Firebase configuration
│   ├── types.ts                 # TypeScript definitions
│   └── tools.ts                 # Utility functions
└── pages/                       # Main application pages
```

### Development Commands:
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build

### Environment Setup:
Create `.env` file with Firebase configuration:
```
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_domain
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_bucket
```

### Recent Bug Fixes:
- Fixed video preview for Vimeo videos
- Added support for both old and new lesson data structures
- Improved error handling in exercise loading
- Enhanced RTL support for Hebrew interface

### Known Issues:
- Some TypeScript strict mode warnings (handled with eslint-disable)
- Exercise type definitions need refinement
- Some legacy components need TypeScript updates

### Next Steps:
1. Add video upload functionality
2. Implement exercise editing interface
3. Add bulk media management
4. Enhance user analytics dashboard