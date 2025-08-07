import { storage } from '../utils/firebase';
import { ref, uploadBytesResumable, getDownloadURL, deleteObject, UploadTaskSnapshot } from 'firebase/storage';

// ממשק להעלאת קובץ
export interface UploadFileOptions {
  file: File;
  folder: 'lessons' | 'exercises' | 'programs' | 'attachments';
  onProgress?: (progress: number) => void;
  onError?: (error: Error) => void;
  onComplete?: (downloadURL: string) => void;
}

// ממשק לתוצאת העלאה
export interface UploadResult {
  url: string;
  fileName: string;
  fileSize: number;
  fileType: string;
}

/**
 * העלאת קובץ ל-Firebase Storage
 */
export const uploadFile = async ({
  file,
  folder,
  onProgress,
  onError,
  onComplete
}: UploadFileOptions): Promise<UploadResult> => {
  try {
    // יצירת שם קובץ ייחודי
    const timestamp = Date.now();
    const sanitizedFileName = file.name.replace(/[^a-zA-Z0-9.-]/g, '_');
    const fileName = `${folder}/${timestamp}_${sanitizedFileName}`;
    
    // יצירת הפניה לקובץ
    const storageRef = ref(storage, fileName);
    
    // התחלת העלאה
    const uploadTask = uploadBytesResumable(storageRef, file);
    
    // מעקב אחר התקדמות
    return new Promise((resolve, reject) => {
      uploadTask.on(
        'state_changed',
        (snapshot: UploadTaskSnapshot) => {
          const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          if (onProgress) {
            onProgress(Math.round(progress));
          }
        },
        (error) => {
          if (onError) {
            onError(error);
          }
          reject(error);
        },
        async () => {
          try {
            const downloadURL = await getDownloadURL(uploadTask.snapshot.ref);
            
            const result: UploadResult = {
              url: downloadURL,
              fileName: fileName,
              fileSize: file.size,
              fileType: file.type
            };
            
            if (onComplete) {
              onComplete(downloadURL);
            }
            
            resolve(result);
          } catch (error) {
            reject(error);
          }
        }
      );
    });
  } catch (error) {
    if (onError && error instanceof Error) {
      onError(error);
    }
    throw error;
  }
};

/**
 * העלאת מספר קבצים במקביל
 */
export const uploadMultipleFiles = async (
  files: File[],
  folder: UploadFileOptions['folder'],
  onProgress?: (fileIndex: number, progress: number) => void
): Promise<UploadResult[]> => {
  const uploadPromises = files.map((file, index) => 
    uploadFile({
      file,
      folder,
      onProgress: (progress) => {
        if (onProgress) {
          onProgress(index, progress);
        }
      }
    })
  );
  
  return Promise.all(uploadPromises);
};

/**
 * מחיקת קובץ מ-Firebase Storage
 */
export const deleteFile = async (fileName: string): Promise<void> => {
  try {
    const fileRef = ref(storage, fileName);
    await deleteObject(fileRef);
  } catch (error) {
    console.error('שגיאה במחיקת קובץ:', error);
    throw error;
  }
};

/**
 * בדיקת סוג קובץ
 */
export const validateFileType = (file: File, allowedTypes: string[]): boolean => {
  return allowedTypes.some(type => {
    if (type.includes('*')) {
      // תמיכה ב-wildcards כמו 'image/*'
      const [category] = type.split('/');
      return file.type.startsWith(category);
    }
    return file.type === type;
  });
};

/**
 * בדיקת גודל קובץ
 */
export const validateFileSize = (file: File, maxSizeInMB: number): boolean => {
  const maxSizeInBytes = maxSizeInMB * 1024 * 1024;
  return file.size <= maxSizeInBytes;
};

// סוגי קבצים מותרים
export const ALLOWED_FILE_TYPES = {
  video: ['video/mp4', 'video/avi', 'video/mov', 'video/wmv', 'video/flv'],
  audio: ['audio/mp3', 'audio/wav', 'audio/m4a', 'audio/ogg'],
  document: [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  ],
  image: ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
};

// גדלי קבצים מקסימליים (במגה-בייט)
export const MAX_FILE_SIZES = {
  video: 500, // 500MB
  audio: 100, // 100MB
  document: 50, // 50MB
  image: 10 // 10MB
};

/**
 * פורמט גודל קובץ לתצוגה
 */
export const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

// Credit: Enhanced by Amit Trabelsi - https://amit-trabelsi.co.il 