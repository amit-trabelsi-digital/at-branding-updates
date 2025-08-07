import { useState } from 'react';
import { 
  Dialog, 
  DialogTitle, 
  DialogContent, 
  DialogActions, 
  Box, 
  Button,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  FormControlLabel,
  FormGroup,
  Checkbox,
  Typography,
  Chip,
  Divider
} from '@mui/material';
import { useForm, Controller } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';
import { TrainingProgram, PublishStatus, DifficultyLevel, SubscriptionType } from '../../utils/types';
import { createTrainingProgram, updateTrainingProgram } from '../../services/coursesApi';
import AppFormTextField from '../general/AppFormTextField';
import AppFormSwitch from '../general/AppFormSwitch';
import AppLoadingBackdrop from '../general/AppLoadingBackdrop';

interface Props {
  open: boolean;
  onClose: () => void;
  program?: TrainingProgram | null;
  onSuccess: () => void;
}

const schema = yup.object().shape({
  title: yup.string().required('שם התוכנית הוא שדה חובה'),
  description: yup.string().required('תיאור התוכנית הוא שדה חובה'),
  category: yup.string().required('קטגוריה היא שדה חובה'),
  type: yup.string().required('סוג התוכנית הוא שדה חובה'),
  difficulty: yup.string().required('רמת קושי היא שדה חובה'),
  estimatedDuration: yup.number().min(0, 'משך התוכנית לא יכול להיות שלילי'),
  subscriptionTypes: yup.array().min(1, 'יש לבחור לפחות סוג מנוי אחד'),
  requireSequential: yup.boolean(),
  isPublished: yup.boolean().required(),
  tags: yup.array().of(yup.string()),
});

type FormData = yup.InferType<typeof schema>;

const TrainingProgramDialog = ({ open, onClose, program, onSuccess }: Props) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [tagInput, setTagInput] = useState('');

  const defaultValues: FormData = {
    title: program?.title || '',
    description: program?.description || '',
    category: program?.category || 'mental',
    type: program?.type || 'course',
    difficulty: program?.difficulty || 'beginner',
    estimatedDuration: program?.estimatedDuration || 60,
    subscriptionTypes: program?.accessRules?.subscriptionTypes || ['basic', 'advanced', 'premium'],
    requireSequential: program?.accessRules?.requireSequential ?? true,
    isPublished: program?.status === 'active' || program?.isPublished || false,
    tags: program?.tags || [],
  };

  const { register, handleSubmit, formState: { errors }, control, watch, setValue } = useForm<FormData>({
    resolver: yupResolver(schema),
    defaultValues,
  });

  const watchedTags = watch('tags');

  const onSubmit = async (data: FormData) => {
    try {
      setLoading(true);
      setError(null);

      const programData = {
        title: data.title,
        description: data.description,
        category: data.category,
        type: data.type as 'course' | 'workshop',
        difficulty: data.difficulty as DifficultyLevel,
        estimatedDuration: data.estimatedDuration || 0,
        accessRules: {
          subscriptionTypes: data.subscriptionTypes as SubscriptionType[] || [],
          requireSequential: data.requireSequential || false,
        },
        status: data.isPublished ? ('active' as PublishStatus) : ('draft' as PublishStatus),
        isPublished: data.isPublished,
        tags: (data.tags || []).filter((tag): tag is string => Boolean(tag)),
      };

      if (program?.id || program?._id) {
        await updateTrainingProgram(program.id || program._id, programData);
      } else {
        await createTrainingProgram(programData as Omit<TrainingProgram, 'id' | '_id' | 'createdAt' | 'updatedAt'>);
      }

      onSuccess();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'שגיאה בשמירת תוכנית האימון');
    } finally {
      setLoading(false);
    }
  };

  const handleAddTag = () => {
    if (tagInput.trim() && !(watchedTags || []).includes(tagInput.trim())) {
      setValue('tags', [...(watchedTags || []), tagInput.trim()]);
      setTagInput('');
    }
  };

  const handleRemoveTag = (tagToRemove: string) => {
    setValue('tags', (watchedTags || []).filter(tag => tag !== tagToRemove));
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>
        {program ? 'עריכת תוכנית אימון' : 'יצירת תוכנית אימון חדשה'}
      </DialogTitle>

      <form onSubmit={handleSubmit(onSubmit)}>
        <DialogContent>
          <Box display="flex" flexDirection="column" gap={2}>
            {/* פרטים בסיסיים */}
            <Typography variant="h6">פרטים בסיסיים</Typography>
            
            <AppFormTextField
              fieldKey="title"
              register={register}
              errors={errors}
              label="שם התוכנית"
              fullWidth
            />

            <AppFormTextField
              fieldKey="description"
              register={register}
              errors={errors}
              label="תיאור התוכנית"
              multiline
              rows={3}
              fullWidth
            />

            <Box display="flex" gap={2}>
              <FormControl fullWidth>
                <InputLabel>קטגוריה</InputLabel>
                <Controller
                  name="category"
                  control={control}
                  render={({ field }) => (
                    <Select {...field} label="קטגוריה">
                      <MenuItem value="mental">מנטלי</MenuItem>
                      <MenuItem value="technical">טכני</MenuItem>
                      <MenuItem value="tactical">טקטי</MenuItem>
                      <MenuItem value="physical">פיזי</MenuItem>
                    </Select>
                  )}
                />
              </FormControl>

              <FormControl fullWidth>
                <InputLabel>סוג</InputLabel>
                <Controller
                  name="type"
                  control={control}
                  render={({ field }) => (
                    <Select {...field} label="סוג">
                      <MenuItem value="course">קורס</MenuItem>
                      <MenuItem value="workshop">סדנה</MenuItem>
                    </Select>
                  )}
                />
              </FormControl>
            </Box>

            <Box display="flex" gap={2}>
              <FormControl fullWidth>
                <InputLabel>רמת קושי</InputLabel>
                <Controller
                  name="difficulty"
                  control={control}
                  render={({ field }) => (
                    <Select {...field} label="רמת קושי">
                      <MenuItem value="beginner">מתחילים</MenuItem>
                      <MenuItem value="intermediate">בינוני</MenuItem>
                      <MenuItem value="advanced">מתקדמים</MenuItem>
                      <MenuItem value="expert">מומחים</MenuItem>
                    </Select>
                  )}
                />
              </FormControl>

              <AppFormTextField
                fieldKey="estimatedDuration"
                register={register}
                errors={errors}
                label="משך משוער (דקות)"
                type="number"
                fullWidth
              />
            </Box>

            <Divider />

            {/* הגדרות גישה */}
            <Typography variant="h6">הגדרות גישה</Typography>

            <FormControl component="fieldset">
              <Typography variant="subtitle2" gutterBottom>סוגי מנוי מורשים</Typography>
              <Controller
                name="subscriptionTypes"
                control={control}
                render={({ field }) => (
                  <FormGroup row>
                    <FormControlLabel
                      control={
                        <Checkbox
                          checked={(field.value || []).includes('basic')}
                          onChange={(e) => {
                            const value = field.value || [];
                            if (e.target.checked) {
                              field.onChange([...value, 'basic']);
                            } else {
                              field.onChange(value.filter(v => v !== 'basic'));
                            }
                          }}
                        />
                      }
                      label="בסיסי"
                    />
                    <FormControlLabel
                      control={
                        <Checkbox
                          checked={(field.value || []).includes('advanced')}
                          onChange={(e) => {
                            const value = field.value || [];
                            if (e.target.checked) {
                              field.onChange([...value, 'advanced']);
                            } else {
                              field.onChange(value.filter(v => v !== 'advanced'));
                            }
                          }}
                        />
                      }
                      label="מתקדם"
                    />
                    <FormControlLabel
                      control={
                        <Checkbox
                          checked={(field.value || []).includes('premium')}
                          onChange={(e) => {
                            const value = field.value || [];
                            if (e.target.checked) {
                              field.onChange([...value, 'premium']);
                            } else {
                              field.onChange(value.filter(v => v !== 'premium'));
                            }
                          }}
                        />
                      }
                      label="פרימיום"
                    />
                  </FormGroup>
                )}
              />
              {errors.subscriptionTypes && (
                <Typography color="error" variant="caption">
                  {errors.subscriptionTypes.message}
                </Typography>
              )}
            </FormControl>

            <AppFormSwitch
              fieldKey="requireSequential"
              register={register}
              label="חובה לסיים שיעור לפני המשך לשיעור הבא"
            />

            <Divider />

            {/* תגיות */}
            <Typography variant="h6">תגיות</Typography>
            
            <Box display="flex" gap={1}>
              <AppFormTextField
                fieldKey="tagInput"
                register={register as any}
                errors={errors}
                label="הוסף תגית"
                value={tagInput}
                onChange={(e) => setTagInput(e.target.value)}
                onKeyPress={(e) => {
                  if (e.key === 'Enter') {
                    e.preventDefault();
                    handleAddTag();
                  }
                }}
                fullWidth
              />
              <Button variant="outlined" onClick={handleAddTag}>
                הוסף
              </Button>
            </Box>

            <Box display="flex" flexWrap="wrap" gap={1}>
              {(watchedTags || []).map((tag, index) => (
                <Chip
                  key={index}
                  label={tag}
                  onDelete={() => handleRemoveTag(tag || '')}
                  color="primary"
                  variant="outlined"
                />
              ))}
            </Box>

            <Divider />

            {/* פרסום */}
            <AppFormSwitch
              fieldKey="isPublished"
              register={register}
              label="פרסם תוכנית"
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
            {program ? 'שמור שינויים' : 'צור תוכנית'}
          </Button>
        </DialogActions>
      </form>

      <AppLoadingBackdrop open={loading} />
    </Dialog>
  );
};

export default TrainingProgramDialog; 