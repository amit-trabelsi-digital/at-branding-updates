import React, { useState, useEffect, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Box,
  Card,
  CardContent,
  CardMedia,
  Typography,
  Chip,
  Button,
  Alert,
  IconButton,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Skeleton,
  Paper,
  Tooltip
} from '@mui/material';
import {
  ArrowBack as ArrowBackIcon,
  Edit as EditIcon,
  School as SchoolIcon,
  Person as PersonIcon,
  Star as StarIcon,
  ExpandMore as ExpandMoreIcon,
  Add as AddIcon,
  PlayArrow as PlayArrowIcon,
  Delete as DeleteIcon,
  AccessTime as AccessTimeIcon,
} from '@mui/icons-material';
import { useSnackbar } from 'notistack';
import { TrainingProgram, Lesson } from '../../utils/types';
import { getTrainingProgram, getLessonsByProgram, getExercisesByLesson } from '../../services/coursesApi';
import AppTitle from '../../components/general/AppTitle';

export const TrainingProgramDetailsPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { enqueueSnackbar } = useSnackbar();
  
  const [program, setProgram] = useState<TrainingProgram | null>(null);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [loading, setLoading] = useState(true);
  const [lessonsLoading, setLessonsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchProgramDetails = useCallback(async () => {
    if (!id) return;
    try {
      setLoading(true);
      const programData = await getTrainingProgram(id);
      setProgram(programData);
      if (programData) {
        fetchLessons(programData._id);
      }
    } catch (err) {
      console.error('Error fetching program details:', err);
      setError('שגיאה בטעינת פרטי התוכנית');
    } finally {
      setLoading(false);
    }
  }, [id]);

  const fetchLessons = useCallback(async (programId: string) => {
    try {
      setLessonsLoading(true);
      const lessonsData = await getLessonsByProgram(programId);
      
      const lessonsWithExercises = await Promise.all(
        lessonsData.map(async (lesson) => {
          try {
            const exercises = await getExercisesByLesson(lesson._id || lesson.id!);
            return { ...lesson, exercises };
          } catch (exerciseError) {
            console.error(`Error fetching exercises for lesson ${lesson._id}:`, exerciseError);
            return { ...lesson, exercises: [] };
          }
        })
      );

      setLessons(lessonsWithExercises);
    } catch (err) {
      console.error('Error fetching lessons:', err);
      setLessons([]);
      enqueueSnackbar('לא ניתן לטעון את השיעורים. נסה שוב מאוחר יותר.', { variant: 'warning' });
    } finally {
      setLessonsLoading(false);
    }
  }, [enqueueSnackbar]);

  useEffect(() => {
    fetchProgramDetails();
  }, [fetchProgramDetails]);

  const handleBack = () => navigate('/dashboard/training-programs');
  const handleAddLesson = () => enqueueSnackbar('הוספת שיעור - בפיתוח', { variant: 'info' });
  const handleEditLesson = (lessonId: string) => enqueueSnackbar(`עריכת שיעור ${lessonId} - בפיתוח`, { variant: 'info' });
  const handleDeleteLesson = (lessonId: string) => enqueueSnackbar(`מחיקת שיעור ${lessonId} - בפיתוח`, { variant: 'info' });
  const handleStartLesson = (lessonId: string) => enqueueSnackbar(`התחלת שיעור ${lessonId} - בפיתוח`, { variant: 'info' });

  if (loading) {
    return (
      <Box sx={{ p: 3, direction: 'rtl' }}>
        <Skeleton variant="rectangular" height={300} sx={{ mb: 3 }} />
        <Skeleton variant="text" height={60} sx={{ mb: 2 }} />
        <Skeleton variant="text" height={40} sx={{ mb: 3 }} />
        <Skeleton variant="rectangular" height={200} />
      </Box>
    );
  }

  if (error || !program) {
    return (
      <Box sx={{ p: 3, direction: 'rtl' }}>
        <Button startIcon={<ArrowBackIcon />} onClick={handleBack} sx={{ mb: 2 }}>
          חזרה
        </Button>
        <Alert severity="error">{error || 'תוכנית לא נמצאה'}</Alert>
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3, direction: 'rtl' }}>
      <Button startIcon={<ArrowBackIcon />} onClick={handleBack} sx={{ mb: 3 }}>
        חזרה לכל התוכניות
      </Button>

      <Card sx={{ mb: 4 }}>
        {program.thumbnailUrl && (
          <CardMedia component="img" height="300" image={program.thumbnailUrl} alt={program.title} sx={{ objectFit: 'cover' }} />
        )}
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
            <AppTitle title={program.title} />
            <Chip label={program.difficulty || 'בינוני'} color="default" size="small" />
          </Box>
          <Typography variant="body1" color="text.secondary" sx={{ mb: 2 }}>
            {program.description}
          </Typography>
          {program.tags && (
            <Box sx={{ mb: 3 }}>
              {program.tags.map((tag, index) => (
                <Chip key={index} label={tag} variant="outlined" size="small" sx={{ mr: 1, mb: 1 }} />
              ))}
            </Box>
          )}
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 3, mb: 3 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <AccessTimeIcon color="action" />
              <Typography variant="body2">{program.estimatedDuration || 'N/A'} דקות</Typography>
            </Box>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <PersonIcon color="action" />
              <Typography variant="body2">{program.instructor || 'איתן עזריה'}</Typography>
            </Box>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <SchoolIcon color="action" />
              <Typography variant="body2">{lessons.length} שיעורים</Typography>
            </Box>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <StarIcon color="action" />
              <Typography variant="body2">{program.status || 'טיוטה'}</Typography>
            </Box>
          </Box>
        </CardContent>
      </Card>

      <Card>
        <CardContent>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
            <Typography variant="h5" component="h2">שיעורי התוכנית</Typography>
            <Button variant="contained" startIcon={<AddIcon />} onClick={handleAddLesson}>הוסף שיעור</Button>
          </Box>

          {lessonsLoading ? (
            <Box>{[1, 2, 3].map(i => <Skeleton key={i} variant="rectangular" height={80} sx={{ mb: 2 }} />)}</Box>
          ) : lessons.length === 0 ? (
            <Alert severity="info">אין שיעורים בתוכנית זו עדיין.</Alert>
          ) : (
            lessons.sort((a, b) => (a.order || 0) - (b.order || 0)).map((lesson, index) => (
              <Accordion key={lesson.id || lesson._id} sx={{ mb: 1 }}>
                <AccordionSummary expandIcon={<ExpandMoreIcon />} sx={{ '& .MuiAccordionSummary-content': { alignItems: 'center', justifyContent: 'space-between' } }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, flex: 1 }}>
                    <Typography variant="h6">שיעור {index + 1}: {lesson.title}</Typography>
                    <Chip label={`${lesson.duration} דקות`} size="small" variant="outlined" />
                    {lesson.isPublished && <Chip label="פורסם" size="small" color="success" />}
                  </Box>
                </AccordionSummary>
                <AccordionDetails>
                  <Box>
                    <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>{lesson.description}</Typography>
                    
                    {lesson.exercises && lesson.exercises.length > 0 && (
                      <Box mt={2}>
                        <Typography variant="subtitle1" gutterBottom>תרגילים:</Typography>
                        {lesson.exercises.map((exercise) => (
                          <Paper key={exercise._id} sx={{ p: 2, mb: 1, backgroundColor: '#f5f5f5', borderRadius: 2 }}>
                            <Box display="flex" justifyContent="space-between" alignItems="center">
                              <Box>
                                <Typography variant="body1" fontWeight="bold">{exercise.title}</Typography>
                                <Typography variant="body2" color="text.secondary">{exercise.description}</Typography>
                              </Box>
                              <Chip label={exercise.type} size="small" />
                            </Box>
                          </Paper>
                        ))}
                      </Box>
                    )}

                    <Box sx={{ mb: 2, mt: 2, display: 'flex', justifyContent: 'space-between', color: 'text.secondary' }}>
                      <Typography variant="caption">נוצר: {new Date(lesson.createdAt).toLocaleDateString('he-IL')}</Typography>
                      <Typography variant="caption">עודכן: {new Date(lesson.updatedAt).toLocaleDateString('he-IL')}</Typography>
                    </Box>

                    <Box sx={{ display: 'flex', gap: 1, mt: 2 }}>
                      <Tooltip title="התחל שיעור">
                        <Button variant="contained" startIcon={<PlayArrowIcon />} onClick={() => handleStartLesson(lesson.id!)} size="small">התחל</Button>
                      </Tooltip>
                      <Tooltip title="ערוך שיעור">
                        <IconButton onClick={() => handleEditLesson(lesson.id!)} size="small" color="primary"><EditIcon /></IconButton>
                      </Tooltip>
                      <Tooltip title="מחק שיעור">
                        <IconButton onClick={() => handleDeleteLesson(lesson.id!)} size="small" color="error"><DeleteIcon /></IconButton>
                      </Tooltip>
                    </Box>
                  </Box>
                </AccordionDetails>
              </Accordion>
            ))
          )}
        </CardContent>
      </Card>
    </Box>
  );
}; 