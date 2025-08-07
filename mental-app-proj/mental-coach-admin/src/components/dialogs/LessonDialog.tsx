import { useState } from 'react';
import { Dialog, DialogTitle, DialogContent, DialogActions, Box, Button } from '@mui/material';
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';
import { Lesson } from '../../utils/types';
import { addLessonToProgram, updateLesson } from '../../services/coursesApi';
import AppFormTextField from '../general/AppFormTextField';
import AppFormSwitch from '../general/AppFormSwitch';
import AppLoadingBackdrop from '../general/AppLoadingBackdrop';

interface Props {
  open: boolean;
  onClose: () => void;
  programId: string;
  lesson?: Lesson | null;
  onSuccess: () => void;
}

const schema = yup.object().shape({
  title: yup.string().required('שם השיעור הוא שדה חובה'),
  description: yup.string().required('תיאור השיעור הוא שדה חובה'),
  duration: yup.number().required('משך השיעור הוא שדה חובה').min(1, 'משך השיעור חייב להיות לפחות דקה אחת'),
  isPublished: yup.boolean().required(),
});

type FormData = {
  title: string;
  description: string;
  duration: number;
  isPublished: boolean;
};

const LessonDialog = ({ open, onClose, programId, lesson, onSuccess }: Props) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const defaultValues: FormData = {
    title: lesson?.title || '',
    description: lesson?.description || '',
    duration: lesson?.duration || 30,
    isPublished: lesson?.isPublished || false,
  };

  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: yupResolver(schema),
    defaultValues,
  });

  const onSubmit = async (data: FormData) => {
    try {
      setLoading(true);
      setError(null);

      if (lesson?.id) {
        await updateLesson(programId, lesson.id, data);
      } else {
        await addLessonToProgram(programId, {
          ...data,
          order: 1, // TODO: Calculate correct order
          content: { primaryContent: data.description },
          media: {},
          trainingProgramId: programId,
          lessonNumber: 1, // TODO: Calculate lesson number
          contentStatus: {
            isPublished: data.isPublished,
            hasContent: true,
            needsReview: false,
          },
        });
      }

      onSuccess();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'שגיאה בשמירת השיעור');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>
        {lesson ? 'עריכת שיעור' : 'יצירת שיעור חדש'}
      </DialogTitle>

      <form onSubmit={handleSubmit(onSubmit)}>
        <DialogContent>
          <Box display="flex" flexDirection="column" gap={2}>
            <AppFormTextField
              fieldKey="title"
              register={register}
              errors={errors}
              label="שם השיעור"
              fullWidth
            />

            <AppFormTextField
              fieldKey="description"
              register={register}
              errors={errors}
              label="תיאור השיעור"
              multiline
              rows={4}
              fullWidth
            />

            <AppFormTextField
              fieldKey="duration"
              register={register}
              errors={errors}
              label="משך השיעור (בדקות)"
              type="number"
              fullWidth
            />

            <AppFormSwitch
              fieldKey="isPublished"
              register={register}
              label="פרסם שיעור"
            />

            {error && (
              <Box color="error.main">
                {error}
              </Box>
            )}
          </Box>
        </DialogContent>

        <DialogActions>
          <Button onClick={onClose} color="inherit">
            ביטול
          </Button>
          <Button type="submit" color="primary" variant="contained">
            {lesson ? 'שמור שינויים' : 'צור שיעור'}
          </Button>
        </DialogActions>
      </form>

      <AppLoadingBackdrop open={loading} />
    </Dialog>
  );
};

export default LessonDialog; 