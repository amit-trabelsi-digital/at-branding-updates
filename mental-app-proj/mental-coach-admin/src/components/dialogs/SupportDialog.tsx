import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  Box,
  Typography,
  Alert,
  CircularProgress,
  IconButton,
  Chip,
  Stack,
} from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';
import AttachFileIcon from '@mui/icons-material/AttachFile';
import { useSnackbar } from 'notistack';
import { useUser } from '../../hooks/useUser';
import { useLocation } from 'react-router-dom';
import { appFetch } from '../../services/fetch';

interface SupportDialogProps {
  open: boolean;
  onClose: () => void;
  openDialog?: string; // שם הדיאלוג/פופאפ הפתוח
}

const SupportDialog: React.FC<SupportDialogProps> = ({ open, onClose, openDialog }) => {
  const { user } = useUser();
  const location = useLocation();
  const { enqueueSnackbar } = useSnackbar();
  
  const [subject, setSubject] = useState('');
  const [description, setDescription] = useState('');
  const [attachments, setAttachments] = useState<File[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [systemInfo, setSystemInfo] = useState({
    environment: import.meta.env.MODE || 'production',
    hostname: '',
    userAgent: '',
    ipAddress: ''
  });

  useEffect(() => {
    // Get system information
    if (typeof window !== 'undefined') {
      setSystemInfo({
        environment: import.meta.env.MODE || 'production',
        hostname: window.location.hostname,
        userAgent: navigator.userAgent,
        ipAddress: '' // Will be filled by the server
      });
    }
  }, []);

  const handleSubmit = async () => {
    if (!subject || !description) {
      enqueueSnackbar('נא למלא נושא ותיאור', { variant: 'error' });
      return;
    }

    setIsSubmitting(true);

    try {
      const supportData = {
        subject,
        description,
        userEmail: user?.email || 'Unknown',
        userName: user?.displayName || user?.email || 'Unknown User',
        currentPage: window.location.href,
        dateTime: new Date().toLocaleString('he-IL'),
        openDialog: openDialog,
        environment: systemInfo.environment,
        hostname: systemInfo.hostname,
        userAgent: systemInfo.userAgent,
        attachments: [] // TODO: implement file upload
      };

      await appFetch('/api/support', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(supportData),
      });

      enqueueSnackbar('הפנייה נשלחה בהצלחה! נחזור אליך בהקדם', { variant: 'success' });
      handleClose();
    } catch (error) {
      console.error('Error sending support request:', error);
      enqueueSnackbar('שגיאה בשליחת הפנייה. אנא נסה שוב', { variant: 'error' });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleClose = () => {
    setSubject('');
    setDescription('');
    setAttachments([]);
    onClose();
  };

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (event.target.files) {
      setAttachments(Array.from(event.target.files));
    }
  };

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="sm"
      fullWidth
      dir="rtl"
    >
      <DialogTitle sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h6">פנייה לתמיכה</Typography>
        <IconButton onClick={handleClose} size="small">
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      
      <DialogContent>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 1 }}>
          {/* מידע משתמש */}
          <Alert severity="info" sx={{ textAlign: 'right' }}>
            <Box>
              <Typography variant="body2" sx={{ direction: 'rtl' }}>
                <strong>משתמש:</strong> {user?.displayName || user?.email}
              </Typography>
              <Typography variant="body2" sx={{ direction: 'rtl' }}>
                <strong>דוא"ל:</strong> {user?.email}
              </Typography>
              <Typography variant="body2" sx={{ direction: 'rtl' }}>
                <strong>עמוד נוכחי:</strong> {location.pathname}
              </Typography>
              <Typography variant="body2" sx={{ direction: 'rtl' }}>
                <strong>תאריך ושעה:</strong> {new Date().toLocaleString('he-IL')}
              </Typography>
              <Typography variant="body2" sx={{ direction: 'rtl' }}>
                <strong>סביבה:</strong> {systemInfo.environment}
              </Typography>
              <Typography variant="body2" sx={{ direction: 'rtl' }}>
                <strong>דומיין:</strong> {systemInfo.hostname}
              </Typography>
              {openDialog && (
                <Typography variant="body2" sx={{ direction: 'rtl' }}>
                  <strong>חלון פתוח:</strong> {openDialog}
                </Typography>
              )}
            </Box>
          </Alert>

          {/* נושא */}
          <TextField
            label="נושא *"
            value={subject}
            onChange={(e) => setSubject(e.target.value)}
            fullWidth
            variant="outlined"
            sx={{ 
              '& .MuiInputBase-input': { 
                textAlign: 'right',
                direction: 'rtl' 
              },
              '& .MuiInputLabel-root': { 
                right: 14,
                left: 'unset',
                transformOrigin: 'right',
                textAlign: 'right'
              },
              '& .MuiInputLabel-shrink': {
                right: 14,
                left: 'unset'
              }
            }}
          />

          {/* תיאור */}
          <TextField
            label="תיאור המקרה *"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            fullWidth
            multiline
            rows={4}
            variant="outlined"
            placeholder="נא לתאר את הבעיה בפירוט..."
            sx={{ 
              '& .MuiInputBase-input': { 
                textAlign: 'right',
                direction: 'rtl' 
              },
              '& .MuiInputLabel-root': { 
                right: 14,
                left: 'unset',
                transformOrigin: 'right',
                textAlign: 'right'
              },
              '& .MuiInputLabel-shrink': {
                right: 14,
                left: 'unset'
              },
              '& ::placeholder': {
                textAlign: 'right'
              }
            }}
          />

          {/* העלאת קבצים */}
          <Box>
            <Button
              variant="outlined"
              component="label"
              startIcon={<AttachFileIcon />}
              fullWidth
            >
              הוסף קבצים (עד 5)
              <input
                type="file"
                hidden
                multiple
                onChange={handleFileChange}
                accept="image/*,.pdf,.doc,.docx"
              />
            </Button>
            
            {attachments.length > 0 && (
              <Stack direction="row" spacing={1} sx={{ mt: 1, flexWrap: 'wrap' }}>
                {attachments.map((file, index) => (
                  <Chip
                    key={index}
                    label={file.name}
                    onDelete={() => {
                      setAttachments(attachments.filter((_, i) => i !== index));
                    }}
                    size="small"
                  />
                ))}
              </Stack>
            )}
          </Box>
        </Box>
      </DialogContent>

      <DialogActions sx={{ px: 3, pb: 2 }}>
        <Button onClick={handleClose} variant="outlined">
          ביטול
        </Button>
        <Button
          onClick={handleSubmit}
          variant="contained"
          disabled={isSubmitting || !subject || !description}
          startIcon={isSubmitting && <CircularProgress size={20} />}
        >
          {isSubmitting ? 'שולח...' : 'שלח פנייה'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default SupportDialog;