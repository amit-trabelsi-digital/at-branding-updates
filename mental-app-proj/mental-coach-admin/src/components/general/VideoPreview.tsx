import React, { useState, useEffect } from 'react';
import { Box, Typography, Alert, CircularProgress, IconButton } from '@mui/material';
import { PlayArrow as PlayIcon, OpenInNew as OpenIcon } from '@mui/icons-material';

interface VideoPreviewProps {
  videoUrl: string;
  thumbnailUrl?: string;
  title?: string;
  onVideoLoad?: (duration: number) => void;
}

const VideoPreview: React.FC<VideoPreviewProps> = ({ 
  videoUrl, 
  thumbnailUrl, 
  title,
  onVideoLoad 
}) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [videoData, setVideoData] = useState<{
    title: string;
    thumbnail?: string;
    duration?: number;
    embedUrl: string;
    type: 'vimeo' | 'youtube' | 'regular';
  } | null>(null);

  useEffect(() => {
    if (!videoUrl || videoUrl.trim() === '') {
      setVideoData(null);
      setError(null);
      return;
    }

    // דחיית הטעינה כדי לא לבצע קריאות מיותרות בזמן הקלדה
    const timeoutId = setTimeout(() => {
      loadVideoData();
    }, 500);

    return () => clearTimeout(timeoutId);
  }, [videoUrl]);

  const loadVideoData = async () => {
    setLoading(true);
    setError(null);

    try {
      // זיהוי סוג הווידאו
      if (videoUrl.includes('vimeo.com')) {
        await loadVimeoVideo(videoUrl);
      } else if (videoUrl.includes('youtube.com') || videoUrl.includes('youtu.be')) {
        await loadYouTubeVideo(videoUrl);
      } else if (videoUrl.startsWith('http')) {
        // וידאו רגיל
        await loadRegularVideo(videoUrl);
      } else {
        setError('כתובת לא תקינה - הכנס קישור מלא');
      }
    } catch (err) {
      setError('שגיאה בטעינת הווידאו - בדוק את הקישור');
      console.error('Video loading error:', err);
    } finally {
      setLoading(false);
    }
  };

  const loadVimeoVideo = async (url: string) => {
    const videoId = extractVimeoId(url);
    if (!videoId) throw new Error('Invalid Vimeo URL');

    // בממשק הניהול - פשוט מציגים את הוידאו בלי לטעון מטאדאטה מ-Vimeo
    setVideoData({
      title: title || `Vimeo Video ${videoId}`,
      thumbnail: `https://vumbnail.com/${videoId}.jpg`, // שירות חיצוני לתמונות ממוזערות של Vimeo
      embedUrl: `https://player.vimeo.com/video/${videoId}`,
      type: 'vimeo'
    });

    // קריאה לפונקציה אם היא קיימת (למקרה שרוצים לעדכן את משך הוידאו)
    if (onVideoLoad) {
      onVideoLoad(0); // אין לנו את משך הוידאו, אז נעביר 0
    }
  };

  const loadYouTubeVideo = async (url: string) => {
    const videoId = extractYouTubeId(url);
    if (!videoId) throw new Error('Invalid YouTube URL');

    setVideoData({
      title: title || 'YouTube Video',
      thumbnail: `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg`,
      embedUrl: `https://www.youtube.com/embed/${videoId}`,
      type: 'youtube'
    });
  };

  const loadRegularVideo = async (url: string) => {
    setVideoData({
      title: title || 'Video',
      thumbnail: thumbnailUrl,
      embedUrl: url,
      type: 'regular'
    });
  };

  const extractVimeoId = (url: string): string | null => {
    const match = url.match(/vimeo\.com\/(\d+)/);
    return match ? match[1] : null;
  };

  const extractYouTubeId = (url: string): string | null => {
    const match = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/);
    return match ? match[1] : null;
  };

  if (!videoUrl) {
    return null;
  }

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
        <CircularProgress />
        <Typography sx={{ ml: 2 }}>טוען וידאו...</Typography>
      </Box>
    );
  }

  if (error) {
    return (
      <Alert severity="error" sx={{ mb: 2 }}>
        {error}
      </Alert>
    );
  }

  if (!videoData) {
    return null;
  }

  return (
    <Box sx={{ mb: 2 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
        <Typography variant="subtitle2">
          תצוגה מקדימה של הווידאו:
        </Typography>
        {videoData && (
          <IconButton 
            size="small" 
            onClick={() => window.open(videoUrl, '_blank')}
            title="פתח בחלון חדש"
          >
            <OpenIcon fontSize="small" />
          </IconButton>
        )}
      </Box>
      <Box
        sx={{
          position: 'relative',
          width: '100%',
          height: 200,
          borderRadius: 1,
          overflow: 'hidden',
          backgroundColor: '#f5f5f5',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center'
        }}
      >
        {videoData.thumbnail ? (
          <Box
            sx={{
              width: '100%',
              height: '100%',
              backgroundImage: `url(${videoData.thumbnail})`,
              backgroundSize: 'cover',
              backgroundPosition: 'center',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer'
            }}
            onClick={() => window.open(videoUrl, '_blank')}
          >
            <Box
              sx={{
                backgroundColor: 'rgba(0,0,0,0.7)',
                borderRadius: '50%',
                width: 60,
                height: 60,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: 'white'
              }}
            >
              <PlayIcon sx={{ fontSize: 30 }} />
            </Box>
          </Box>
        ) : (
          <Box sx={{ textAlign: 'center' }}>
            <PlayIcon sx={{ fontSize: 40, color: '#ccc', mb: 1 }} />
            <Typography variant="body2" color="text.secondary">
              {videoData.title}
            </Typography>
          </Box>
        )}
      </Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mt: 1 }}>
        {videoData.duration && (
          <Typography variant="caption" color="text.secondary">
            משך: {Math.floor(videoData.duration / 60)}:{(videoData.duration % 60).toString().padStart(2, '0')}
          </Typography>
        )}
        <Typography variant="caption" color="text.secondary">
          {videoData.type === 'vimeo' ? 'Vimeo' : 
           videoData.type === 'youtube' ? 'YouTube' : 
           'וידאו ישיר'}
        </Typography>
      </Box>
    </Box>
  );
};

export default VideoPreview; 