import React, { useState } from 'react';
import {
  Box,
  Button,
  Typography,
  LinearProgress,
  Alert,
  Card,
  CardMedia,
  IconButton,
  Tooltip
} from '@mui/material';
import {
  CloudUpload as UploadIcon,
  Delete as DeleteIcon,
  Image as ImageIcon
} from '@mui/icons-material';
import { uploadFile, validateFileType, validateFileSize, ALLOWED_FILE_TYPES, MAX_FILE_SIZES } from '../../services/firebaseStorage';
import { useSnackbar } from 'notistack';

interface ImageUploadProps {
  value?: string; // URL של תמונה קיימת
  onChange: (url: string | null) => void; // פונקציה לעדכון ה-URL
  label?: string;
  folder?: 'lessons' | 'exercises' | 'programs' | 'attachments';
  disabled?: boolean;
  maxSizeInMB?: number;
  aspectRatio?: number; // יחס גובה-רוחב (width/height)
  previewHeight?: number;
}

const ImageUpload: React.FC<ImageUploadProps> = ({
  value,
  onChange,
  label = 'תמונה',
  folder = 'lessons',
  disabled = false,
  maxSizeInMB = MAX_FILE_SIZES.image,
  aspectRatio,
  previewHeight = 200
}) => {
  const [uploading, setUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const [dragOver, setDragOver] = useState(false);
  const { enqueueSnackbar } = useSnackbar();

  const handleFileSelect = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    // איפוס שגיאות
    setError(null);

    // בדיקת סוג קובץ
    if (!validateFileType(file, ALLOWED_FILE_TYPES.image)) {
      setError('סוג קובץ לא נתמך. אנא בחר תמונה (JPG, PNG, GIF, WebP)');
      return;
    }

    // בדיקת גודל קובץ
    if (!validateFileSize(file, maxSizeInMB)) {
      setError(`גודל הקובץ חורג מהמותר (${maxSizeInMB}MB)`);
      return;
    }

    try {
      setUploading(true);
      setUploadProgress(0);

      const result = await uploadFile({
        file,
        folder,
        onProgress: (progress) => {
          setUploadProgress(progress);
        }
      });

      onChange(result.url);
      enqueueSnackbar('התמונה הועלתה בהצלחה', { variant: 'success' });
    } catch (error) {
      console.error('Error uploading image:', error);
      setError('שגיאה בהעלאת התמונה');
      enqueueSnackbar('שגיאה בהעלאת התמונה', { variant: 'error' });
    } finally {
      setUploading(false);
      setUploadProgress(0);
    }
  };

  const handleRemove = () => {
    onChange(null);
    enqueueSnackbar('התמונה הוסרה', { variant: 'info' });
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (!disabled && !uploading) {
      setDragOver(true);
    }
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setDragOver(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setDragOver(false);
    
    if (disabled || uploading) return;
    
    const files = e.dataTransfer.files;
    if (files.length > 0) {
      const file = files[0];
             // Handle file directly
       const fakeEvent = {
         target: {
           files: [file]
         }
       } as unknown as React.ChangeEvent<HTMLInputElement>;
       handleFileSelect(fakeEvent);
    }
  };

  return (
    <Box>
      <Typography variant="subtitle2" sx={{ mb: 1 }}>
        {label}
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      {value && !uploading ? (
        <Card sx={{ mb: 2, maxWidth: 400 }}>
          <CardMedia
            component="img"
            height={previewHeight}
            image={value}
            alt={label}
            sx={{
              objectFit: 'cover',
              aspectRatio: aspectRatio || 'auto'
            }}
          />
          <Box sx={{ p: 1, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <Typography variant="caption" color="text.secondary">
              תמונה נוכחית
            </Typography>
            <Tooltip title="הסר תמונה">
              <IconButton
                size="small"
                color="error"
                onClick={handleRemove}
                disabled={disabled}
              >
                <DeleteIcon />
              </IconButton>
            </Tooltip>
          </Box>
        </Card>
      ) : (
        <Box
          sx={{
            border: `2px dashed ${dragOver ? '#1976d2' : '#ccc'}`,
            borderRadius: 2,
            p: 3,
            textAlign: 'center',
            backgroundColor: dragOver ? '#e3f2fd' : '#f9f9f9',
            mb: 2,
            minHeight: previewHeight,
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
            transition: 'all 0.2s ease'
          }}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
        >
          {uploading ? (
            <Box sx={{ width: '100%', maxWidth: 300 }}>
              <Typography variant="body2" sx={{ mb: 1 }}>
                מעלה תמונה... {uploadProgress}%
              </Typography>
              <LinearProgress variant="determinate" value={uploadProgress} />
            </Box>
          ) : (
            <>
              <ImageIcon sx={{ fontSize: 48, color: '#ccc', mb: 2 }} />
              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                {dragOver ? 'שחרר כדי להעלות' : value ? 'בחר תמונה חדשה או גרור לכאן' : 'בחר תמונה או גרור לכאן'}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                JPG, PNG, GIF, WebP עד {maxSizeInMB}MB
              </Typography>
            </>
          )}
        </Box>
      )}

      <Button
        variant="outlined"
        component="label"
        startIcon={<UploadIcon />}
        disabled={disabled || uploading}
        fullWidth
      >
        {value ? 'שנה תמונה' : 'העלה תמונה'}
        <input
          type="file"
          hidden
          accept="image/*"
          onChange={handleFileSelect}
          disabled={disabled || uploading}
        />
      </Button>

      {aspectRatio && (
        <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
          מומלץ יחס גובה-רוחב: {aspectRatio.toFixed(2)}
        </Typography>
      )}
    </Box>
  );
};

export default ImageUpload;

// Credit: Developed by Amit Trabelsi - https://amit-trabelsi.co.il 