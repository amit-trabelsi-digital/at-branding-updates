import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Chip,
  Button,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Alert,
  CircularProgress,
  IconButton,
  Tooltip
} from '@mui/material';
import {
  ExpandMore as ExpandMoreIcon,
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Quiz as QuizIcon,
  TextFields as TextFieldsIcon,
  VideoLibrary as VideoIcon,
  Assignment as AssignmentIcon,
  Psychology as PsychologyIcon,
  Tune as TuneIcon
} from '@mui/icons-material';
import { Exercise } from '../../utils/types';
import { getExercisesByLesson } from '../../services/coursesApi';
import { useSnackbar } from 'notistack';

interface ExercisesListProps {
  lessonId: string;
  onEditExercise?: (exercise: Exercise) => void;
  onDeleteExercise?: (exerciseId: string) => void;
  onAddExercise?: () => void;
  readOnly?: boolean;
}

const ExercisesList: React.FC<ExercisesListProps> = ({
  lessonId,
  onEditExercise,
  onDeleteExercise,
  onAddExercise,
  readOnly = false
}) => {
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { enqueueSnackbar } = useSnackbar();

  useEffect(() => {
    loadExercises();
  }, [lessonId]);

  const loadExercises = async () => {
    try {
      setLoading(true);
      setError(null);
      const exercisesData = await getExercisesByLesson(lessonId);
      setExercises(exercisesData);
    } catch (err) {
      console.error('Error loading exercises:', err);
      setError('שגיאה בטעינת התרגילים');
      enqueueSnackbar('שגיאה בטעינת התרגילים', { variant: 'error' });
    } finally {
      setLoading(false);
    }
  };

  const getExerciseIcon = (type: string) => {
    switch (type) {
      case 'questionnaire':
        return <QuizIcon />;
      case 'text_input':
        return <TextFieldsIcon />;
      case 'video_reflection':
        return <VideoIcon />;
      case 'action_plan':
        return <AssignmentIcon />;
      case 'mental_visualization':
        return <PsychologyIcon />;
      case 'content_slider':
        return <TuneIcon />;
      default:
        return <QuizIcon />;
    }
  };

  const getExerciseTypeLabel = (type: string) => {
    switch (type) {
      case 'questionnaire':
        return 'שאלון';
      case 'text_input':
        return 'קלט טקסט';
      case 'video_reflection':
        return 'רפלקציה על וידאו';
      case 'action_plan':
        return 'תוכנית פעולה';
      case 'mental_visualization':
        return 'דמיון מודרך';
      case 'content_slider':
        return 'סליידר תוכן';
      default:
        return type;
    }
  };

  const renderExerciseContent = (exercise: Exercise) => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const content = exercise.content as Record<string, any>; // Temporary workaround for flexible content structure
    
    switch (exercise.type as string) {
      case 'text_input':
        return (
          <Box>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
              שאלות לתשובה חופשית:
            </Typography>
            {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
            {content.prompts?.map((prompt: Record<string, any>, index: number) => (
              <Box key={prompt.promptId || index} sx={{ mb: 1, p: 1, backgroundColor: '#f5f5f5', borderRadius: 1 }}>
                <Typography variant="body2" sx={{ fontWeight: 'medium' }}>
                  {index + 1}. {prompt.text}
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  אורך מקסימלי: {prompt.maxLength} תווים
                  {prompt.required && ' • חובה'}
                </Typography>
              </Box>
            ))}
          </Box>
        );
      
      case 'questionnaire':
        return (
          <Box>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
              שאלות שאלון:
            </Typography>
            {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
            {content.questions?.map((question: Record<string, any>, index: number) => (
              <Box key={question.questionId || index} sx={{ mb: 1, p: 1, backgroundColor: '#f5f5f5', borderRadius: 1 }}>
                <Typography variant="body2" sx={{ fontWeight: 'medium' }}>
                  {index + 1}. {question.text}
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  סוג: {question.type} • אפשרויות: {question.options?.length || 0}
                </Typography>
              </Box>
            ))}
          </Box>
        );
      
      case 'action_plan':
        return (
          <Box>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
              חלקי תוכנית הפעולה:
            </Typography>
            {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
            {content.sections?.map((section: Record<string, any>, index: number) => (
              <Box key={section.sectionId || index} sx={{ mb: 1, p: 1, backgroundColor: '#f5f5f5', borderRadius: 1 }}>
                <Typography variant="body2" sx={{ fontWeight: 'medium' }}>
                  {section.title}
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  {section.prompts?.length || 0} שאלות
                </Typography>
              </Box>
            ))}
          </Box>
        );
      
      default:
        return (
          <Typography variant="body2" color="text.secondary">
            תוכן התרגיל זמין בעריכה
          </Typography>
        );
    }
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
        <CircularProgress />
        <Typography sx={{ ml: 2 }}>טוען תרגילים...</Typography>
      </Box>
    );
  }

  if (error) {
    return (
      <Alert severity="error" sx={{ mb: 2 }}>
        {error}
        <Button onClick={loadExercises} sx={{ ml: 2 }}>
          נסה שוב
        </Button>
      </Alert>
    );
  }

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
        <Typography variant="h6">
          תרגילים ({exercises.length})
        </Typography>
        {!readOnly && (
          <Button
            variant="outlined"
            startIcon={<AddIcon />}
            onClick={onAddExercise}
            size="small"
          >
            הוסף תרגיל
          </Button>
        )}
      </Box>

      {exercises.length === 0 ? (
        <Alert severity="info" sx={{ mb: 2 }}>
          אין תרגילים מוגדרים לשיעור זה
          {!readOnly && (
            <>
              <br />
              <Button
                variant="outlined"
                startIcon={<AddIcon />}
                onClick={onAddExercise}
                sx={{ mt: 1 }}
                size="small"
              >
                הוסף תרגיל ראשון
              </Button>
            </>
          )}
        </Alert>
      ) : (
        exercises
          .sort((a, b) => (a.settings.order || 0) - (b.settings.order || 0))
          .map((exercise) => (
            <Accordion key={exercise._id} sx={{ mb: 1 }}>
              <AccordionSummary
                expandIcon={<ExpandMoreIcon />}
                sx={{
                  '& .MuiAccordionSummary-content': {
                    alignItems: 'center',
                    justifyContent: 'space-between'
                  }
                }}
              >
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, flex: 1 }}>
                  {getExerciseIcon(exercise.type)}
                  <Box>
                    <Typography variant="subtitle1" sx={{ fontWeight: 'medium' }}>
                      {exercise.title}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      {exercise.description}
                    </Typography>
                  </Box>
                </Box>
                <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                  <Chip
                    label={getExerciseTypeLabel(exercise.type)}
                    size="small"
                    variant="outlined"
                  />
                  <Chip
                    label={`${exercise.settings.points || 0} נקודות`}
                    size="small"
                    color="primary"
                  />
                  {exercise.settings.required && (
                    <Chip
                      label="חובה"
                      size="small"
                      color="error"
                    />
                  )}
                </Box>
              </AccordionSummary>
              <AccordionDetails>
                <Box>
                  {renderExerciseContent(exercise)}
                  
                  <Box sx={{ mt: 2, pt: 2, borderTop: '1px solid #e0e0e0' }}>
                    <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 1 }}>
                      הגדרות תרגיל:
                    </Typography>
                    <Box sx={{ display: 'flex', gap: 2, mb: 2 }}>
                      <Typography variant="caption">
                        סדר: {exercise.settings.order || 0}
                      </Typography>
                      {exercise.settings.timeLimit && (
                        <Typography variant="caption">
                          מגבלת זמן: {Math.floor(exercise.settings.timeLimit / 60)} דקות
                        </Typography>
                      )}
                      <Typography variant="caption">
                        ניתן לחזור: {exercise.settings.allowRetake ? 'כן' : 'לא'}
                      </Typography>
                    </Box>
                    
                    {!readOnly && (
                      <Box sx={{ display: 'flex', gap: 1 }}>
                        <Tooltip title="ערוך תרגיל">
                          <IconButton
                            size="small"
                            onClick={() => onEditExercise?.(exercise)}
                          >
                            <EditIcon />
                          </IconButton>
                        </Tooltip>
                        <Tooltip title="מחק תרגיל">
                          <IconButton
                            size="small"
                            color="error"
                            onClick={() => onDeleteExercise?.(exercise._id)}
                          >
                            <DeleteIcon />
                          </IconButton>
                        </Tooltip>
                      </Box>
                    )}
                  </Box>
                </Box>
              </AccordionDetails>
            </Accordion>
          ))
      )}
    </Box>
  );
};

export default ExercisesList; 