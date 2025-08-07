
import { Drawer, Box, Typography, Button, IconButton } from '@mui/material';
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';
import { Lesson, Exercise } from '../../utils/types';
import { updateLesson, addLessonToProgram, deleteExercise } from '../../services/coursesApi';
import AppFormTextField from '../general/AppFormTextField';
import AppFormSwitch from '../general/AppFormSwitch';
import VideoPreview from '../general/VideoPreview';
import ExercisesList from '../general/ExercisesList';
import ExerciseDialog from '../dialogs/ExerciseDialog';
import ImageUpload from '../general/ImageUpload';
import HighlightsManager from '../general/HighlightsManager';
import { useEffect, useState } from 'react';
import { useSnackbar } from 'notistack';
import { Close as CloseIcon } from '@mui/icons-material';
import AppLoadingBackdrop from '../general/AppLoadingBackdrop';

interface Props {
  open: boolean;
  onClose: () => void;
  programId: string;
  lesson: Lesson | null;
  onSuccess: () => void;
}

const schema = yup.object().shape({
  title: yup.string().required('שם השיעור הוא שדה חובה'),
  shortTitle: yup.string(),
  description: yup.string(), // השדה קיים בסכמה אך לא חובה
  duration: yup.number().required('משך השיעור הוא שדה חובה').min(1, 'משך השיעור חייב להיות לפחות דקה אחת'),
  lessonNumber: yup.number().required('מספר השיעור הוא שדה חובה').min(1, 'מספר השיעור חייב להיות לפחות 1'),
  isPublished: yup.boolean().required(),
  order: yup.number().required('סדר הוא שדה חובה'),
  // תוכן השיעור
  primaryContent: yup.string().required('תוכן השיעור הוא שדה חובה'),
  additionalContent: yup.string(),
  structure: yup.string(),
  notes: yup.string(),
  highlights: yup.array().of(yup.string().required()),
  // מדיה
  videoUrl: yup.string().url('כתובת וידאו לא תקינה'),
  thumbnailUrl: yup.string().url('כתובת תמונה לא תקינה').optional(),
  // ציון
  points: yup.number().min(0, 'נקודות לא יכולות להיות שליליות'),
  bonusPoints: yup.number().min(0, 'נקודות בונוס לא יכולות להיות שליליות'),
  passingScore: yup.number().min(0, 'ציון עובר לא יכול להיות שלילי').max(100, 'ציון עובר לא יכול להיות מעל 100'),
});

type FormData = yup.InferType<typeof schema> & {
  highlights?: string[];
};

const LessonEditDrawer = ({ open, onClose, programId, lesson, onSuccess }: Props) => {
  const { enqueueSnackbar } = useSnackbar();
  const [loading, setLoading] = useState(false);
  const [videoUrl, setVideoUrl] = useState('');
  const [exerciseDialogOpen, setExerciseDialogOpen] = useState(false);
  const [selectedExercise, setSelectedExercise] = useState<Exercise | null>(null);
  const [refreshExercises, setRefreshExercises] = useState(0);
  const [highlights, setHighlights] = useState<string[]>([]);

  const { register, handleSubmit, formState: { errors }, reset, setValue, watch } = useForm<FormData>({
    resolver: yupResolver(schema),
    defaultValues: {
        title: '',
        shortTitle: '',
        description: '',
        duration: 30,
        lessonNumber: 1,
        isPublished: false,
        order: 0,
        primaryContent: '',
        additionalContent: '',
        structure: '',
        notes: '',
        highlights: [],
        videoUrl: '',
        thumbnailUrl: '',
        points: 30,
        bonusPoints: 0,
        passingScore: 80,
    }
  });

  useEffect(() => {
    if (lesson) {
        const videoUrl = lesson.media?.videoUrl || lesson.content?.data?.videoUrl || '';
        const thumbnailUrl = lesson.content?.data?.thumbnailUrl || '';
        const lessonHighlights = lesson.content?.highlights || [];
        
        setValue('title', lesson.title);
        setValue('shortTitle', lesson.shortTitle || '');
        setValue('duration', lesson.duration);
        setValue('lessonNumber', lesson.lessonNumber);
        setValue('isPublished', lesson.isPublished);
        setValue('order', lesson.order);
        // תוכן - מאחד את התיאור הישן לתוך התוכן העיקרי
        setValue('primaryContent', lesson.content?.primaryContent || lesson.description || '');
        setValue('additionalContent', lesson.content?.additionalContent || '');
        setValue('structure', lesson.content?.structure || '');
        setValue('notes', lesson.content?.notes || '');
        setValue('highlights', lessonHighlights);
        // מדיה
        setValue('videoUrl', videoUrl);
        setValue('thumbnailUrl', thumbnailUrl);
        setVideoUrl(videoUrl);
        // ציון
        setValue('points', lesson.scoring?.points || 30);
        setValue('bonusPoints', lesson.scoring?.bonusPoints || 0);
        setValue('passingScore', lesson.scoring?.passingScore || 80);
        
        setHighlights(lessonHighlights);
    } else {
        reset();
        setVideoUrl('');
        setHighlights([]);
    }
  }, [lesson, setValue, reset]);

  const onSubmit = async (data: FormData) => {
    setLoading(true);
    try {
      const lessonData = {
        ...data,
        description: data.primaryContent || '', // שימוש בתוכן העיקרי בתור תיאור
        trainingProgramId: programId, // הוספת שדה חסר
        content: {
          ...lesson?.content,
          primaryContent: data.primaryContent || '',
          additionalContent: data.additionalContent || '',
          structure: data.structure || '',
          notes: data.notes || '',
          highlights: highlights.filter(h => h.trim()),
        },
        media: {
          ...lesson?.media,
          videoUrl: data.videoUrl || null,
          videoType: data.videoUrl ? 'primary' as const : null,
          videoDuration: data.videoUrl ? data.duration * 60 : 0,
          audioFiles: lesson?.media?.audioFiles || [], // הוספת שדה חסר
          documents: lesson?.media?.documents || [], // הוספת שדה חסר
        },
        contentStatus: { // הוספת שדה חסר
          isPublished: data.isPublished,
          isVisible: true,
          isLocked: false,
          hasContent: Boolean(data.primaryContent || data.videoUrl),
          needsReview: false,
        },
        scoring: { // הוספת שדה חסר
          passingScore: data.passingScore || 80,
          maxScore: 100,
          minimumCompletionTime: 0,
          points: data.points || 30,
          bonusPoints: data.bonusPoints || 0,
          scoreableActions: [],
        }
      };

      if (lesson) {
        await updateLesson(programId, lesson._id, lessonData);
      } else {
        await addLessonToProgram(programId, lessonData);
      }
      onSuccess();
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : lesson ? 'שגיאה בעדכון השיעור' : 'שגיאה ביצירת השיעור';
      enqueueSnackbar(errorMessage, { variant: 'error' });
    } finally {
      setLoading(false);
    }
  };

  const handleAddExercise = () => {
    setSelectedExercise(null);
    setExerciseDialogOpen(true);
  };

  const handleEditExercise = (exercise: Exercise) => {
    setSelectedExercise(exercise);
    setExerciseDialogOpen(true);
  };

  const handleDeleteExercise = async (exerciseId: string) => {
    try {
      await deleteExercise(exerciseId);
      enqueueSnackbar('התרגיל נמחק בהצלחה', { variant: 'success' });
      setRefreshExercises(prev => prev + 1);
    } catch {
      enqueueSnackbar('שגיאה במחיקת התרגיל', { variant: 'error' });
    }
  };

  const handleExerciseSuccess = () => {
    setExerciseDialogOpen(false);
    setSelectedExercise(null);
    setRefreshExercises(prev => prev + 1);
  };

  return (
    <Drawer anchor="left" open={open} onClose={onClose} PaperProps={{ sx: { width: '40%', minWidth: '400px' } }}>
      <Box sx={{ p: 3, display: 'flex', flexDirection: 'column', height: '100%' }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <Typography variant="h5">{lesson ? 'עריכת שיעור' : 'יצירת שיעור חדש'}</Typography>
            <IconButton onClick={onClose}><CloseIcon /></IconButton>
        </Box>

        <form onSubmit={handleSubmit(onSubmit)} style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
          <Box sx={{ p: 2, display: 'flex', flexDirection: 'column', gap: 2, flex: 1, maxHeight: '70vh', overflowY: 'auto' }}>
            {/* מידע בסיסי */}
            <Typography variant="h6" sx={{ mb: 1 }}>מידע בסיסי</Typography>
            <AppFormTextField fieldKey="title" register={register} errors={errors} label="שם השיעור" fullWidth />
            <AppFormTextField fieldKey="shortTitle" register={register} errors={errors} label="כותרת קצרה" fullWidth />
            
            {/* וידאו ראשי */}
            <Typography variant="h6" sx={{ mb: 1, mt: 2 }}>וידאו ראשי</Typography>
            <AppFormTextField 
              fieldKey="videoUrl" 
              register={register} 
              errors={errors} 
              label="קישור לוידאו" 
              fullWidth 
              placeholder="הכנס קישור לוידאו מ-Vimeo, YouTube או קישור ישיר"
              onChange={(e) => setVideoUrl(e.target.value)}
            />
            <VideoPreview 
              videoUrl={watch('videoUrl') || videoUrl} 
              thumbnailUrl={watch('thumbnailUrl')}
              title={watch('title')}
              onVideoLoad={(duration) => setValue('duration', duration)}
            />
            <ImageUpload
              value={watch('thumbnailUrl') || ''}
              onChange={(url) => setValue('thumbnailUrl', url || undefined)}
              label="תמונה ממוזערת (אופציונלי)"
              folder="lessons"
              aspectRatio={16/9}
              previewHeight={120}
            />

            {/* תוכן השיעור */}
            <Typography variant="h6" sx={{ mb: 1, mt: 2 }}>תוכן השיעור</Typography>
            <AppFormTextField 
              fieldKey="primaryContent" 
              register={register} 
              errors={errors} 
              label="תוכן / תיאור שיעור" 
              multiline 
              rows={4} 
              fullWidth 
              placeholder="תאר את התוכן העיקרי של השיעור - מה הלומד יילמד?"
            />
            
            {/* דגשים */}
            <Typography variant="h6" sx={{ mb: 1, mt: 2 }}>דגשים</Typography>
            <AppFormTextField 
              fieldKey="additionalContent" 
              register={register} 
              errors={errors} 
              label="דגשים לקחת" 
              multiline 
              rows={3} 
              fullWidth 
              placeholder="תוכן נוסף, נקודות חשובות"
            />
            
            {/* ניהול הדגשים */}
            <Box sx={{ mt: 2 }}>
              <HighlightsManager
                highlights={highlights}
                onChange={setHighlights}
                label="הדגשים"
                maxItems={10}
              />
            </Box>
            
            <AppFormTextField 
              fieldKey="structure" 
              register={register} 
              errors={errors} 
              label="מבנה השיעור" 
              fullWidth 
              placeholder="למשל: וידאו מרכזי, תרגיל מעשי, דיון"
            />
            <AppFormTextField 
              fieldKey="notes" 
              register={register} 
              errors={errors} 
              label="הערות" 
              multiline 
              rows={2} 
              fullWidth 
              placeholder="הערות פנימיות למדריך"
            />
            
            {/* מדיה נוספת */}
            <Typography variant="h6" sx={{ mb: 1, mt: 2 }}>מדיה נוספת</Typography>
            <Box sx={{ 
              border: '1px dashed #ccc', 
              borderRadius: 1, 
              p: 2, 
              textAlign: 'center',
              backgroundColor: '#f9f9f9'
            }}>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                קבצי אודיו, מסמכים ומשאבים נוספים
              </Typography>
              <Button 
                variant="outlined" 
                size="small"
                onClick={() => enqueueSnackbar('ניהול מדיה נוספת - בפיתוח', { variant: 'info' })}
              >
                הוסף מדיה נוספת
              </Button>
            </Box>
            
            {/* ציונים */}
            <Typography variant="h6" sx={{ mb: 1, mt: 2 }}>ציונים ונקודות</Typography>
            <Box sx={{ display: 'flex', gap: 2 }}>
              <AppFormTextField fieldKey="points" register={register} errors={errors} label="נקודות בסיסיות" type="number" fullWidth />
              <AppFormTextField fieldKey="bonusPoints" register={register} errors={errors} label="נקודות בונוס" type="number" fullWidth />
              <AppFormTextField fieldKey="passingScore" register={register} errors={errors} label="ציון עובר (%)" type="number" fullWidth />
            </Box>
            
            {/* תרגילים */}
            <Typography variant="h6" sx={{ mb: 1, mt: 2 }}>תרגילים</Typography>
            {lesson && (
              <ExercisesList
                key={refreshExercises}
                lessonId={lesson._id}
                onAddExercise={handleAddExercise}
                onEditExercise={handleEditExercise}
                onDeleteExercise={handleDeleteExercise}
              />
            )}

            {/* מספרים וסדר */}
            <Typography variant="h6" sx={{ mb: 1, mt: 2 }}>מספרים וסדר</Typography>
            <Box sx={{ display: 'flex', gap: 2 }}>
              <AppFormTextField fieldKey="lessonNumber" register={register} errors={errors} label="מספר השיעור" type="number" fullWidth />
              <AppFormTextField fieldKey="order" register={register} errors={errors} label="סדר" type="number" fullWidth />
              <AppFormTextField fieldKey="duration" register={register} errors={errors} label="משך (דקות)" type="number" fullWidth />
            </Box>

            {/* הגדרות פרסום */}
            <Typography variant="h6" sx={{ mb: 1, mt: 2 }}>הגדרות פרסום</Typography>
            <AppFormSwitch fieldKey="isPublished" register={register} label="פרסם שיעור" />
          </Box>
          <Box sx={{ p: 2, mt: 'auto' }}>
            <Button type="submit" variant="contained" fullWidth disabled={loading}>
              {lesson ? 'שמור שינויים' : 'צור שיעור'}
            </Button>
          </Box>
        </form>
      </Box>
      <AppLoadingBackdrop open={loading} />
      
      {lesson && (
        <ExerciseDialog
          open={exerciseDialogOpen}
          onClose={() => setExerciseDialogOpen(false)}
          lessonId={lesson._id}
          exercise={selectedExercise}
          onSuccess={handleExerciseSuccess}
        />
      )}
    </Drawer>
  );
};

export default LessonEditDrawer; 