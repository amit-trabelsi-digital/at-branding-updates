import React, { useState, useEffect } from 'react';
import {
  Dialog, DialogTitle, DialogContent, DialogActions, Box, Button,
  FormControl, InputLabel, Select, MenuItem, TextField, Switch, FormControlLabel
} from '@mui/material';
import { Exercise, ExerciseType, QuestionnaireQuestion, ActionPlanField, QuestionOption } from '../../utils/types';
import { createExercise, updateExercise } from '../../services/coursesApi';
import { useSnackbar } from 'notistack';
import { EXERCISE_TYPES } from '../../data/lists';
import ExerciseContentEditor from '../forms/ExerciseContentEditor';

interface ExerciseContent {
  questions?: QuestionnaireQuestion[];
  fields?: ActionPlanField[];
  reflectionQuestion?: string;
  instructions?: string[];
}

interface ExerciseDialogProps {
  open: boolean;
  onClose: () => void;
  lessonId: string;
  exercise: Exercise | null;
  onSuccess: () => void;
}

const ExerciseDialog: React.FC<ExerciseDialogProps> = ({
  open,
  onClose,
  lessonId,
  exercise,
  onSuccess
}) => {
  const { enqueueSnackbar } = useSnackbar();
  const [loading, setLoading] = useState(false);
  
  // Form state
  const [formData, setFormData] = useState({
    type: 'questionnaire' as ExerciseType,
    title: '',
    description: '',
    points: 10,
    required: true,
    order: 0,
    timeLimit: 0,
    allowRetake: true,
    showCorrectAnswers: false
  });

  // Content state based on type
  const [questions, setQuestions] = useState<QuestionnaireQuestion[]>([]);
  const [actionPlanFields, setActionPlanFields] = useState<ActionPlanField[]>([]);
  const [instructions, setInstructions] = useState<string[]>(['']);
  const [reflectionQuestion, setReflectionQuestion] = useState('');

  useEffect(() => {
    if (exercise) {
      // Load existing exercise data
      setFormData({
        type: exercise.type,
        title: exercise.title,
        description: exercise.description,
        points: exercise.settings.points || 10,
        required: exercise.settings.required,
        order: exercise.settings.order || 0,
        timeLimit: exercise.settings.timeLimit || 0,
        allowRetake: exercise.settings.allowRetake || true,
        showCorrectAnswers: exercise.settings.showCorrectAnswers || false
      });

      // Load content based on type
      if (exercise.content.questions) {
        setQuestions(exercise.content.questions);
      }
      if (exercise.content.fields) {
        setActionPlanFields(exercise.content.fields);
      }
      if (exercise.content.instructions) {
        setInstructions(exercise.content.instructions);
      }
      if (exercise.content.reflectionQuestion) {
        setReflectionQuestion(exercise.content.reflectionQuestion);
      }
    } else {
      // Reset for new exercise
      resetForm();
    }
  }, [exercise]);

  const resetForm = () => {
    setFormData({
      type: 'questionnaire',
      title: '',
      description: '',
      points: 10,
      required: true,
      order: 0,
      timeLimit: 0,
      allowRetake: true,
      showCorrectAnswers: false
    });
    setQuestions([]);
    setActionPlanFields([]);
    setInstructions(['']);
    setReflectionQuestion('');
  };

  const handleSave = async () => {
    setLoading(true);
    try {
      // Build content object based on type
      const content: ExerciseContent = {};
      switch (formData.type) {
        case 'questionnaire':
          content.questions = questions;
          break;
        case 'action_plan':
          content.fields = actionPlanFields;
          break;
        case 'video_reflection':
          content.reflectionQuestion = reflectionQuestion;
          break;
        case 'text_input':
          content.instructions = instructions;
          break;
      }
      
      const exerciseData = {
        _id: exercise?._id || '', // הוספת המאפיין החסר
        lessonId,
        ...formData,
        settings: {
          points: formData.points,
          required: formData.required,
          order: formData.order,
          timeLimit: formData.timeLimit,
          allowRetake: formData.allowRetake,
          showCorrectAnswers: formData.showCorrectAnswers
        },
        content
      };

      if (exercise) {
        await updateExercise(exercise._id, exerciseData);
        enqueueSnackbar('התרגיל עודכן בהצלחה', { variant: 'success' });
      } else {
        await createExercise(exerciseData);
        enqueueSnackbar('התרגיל נוצר בהצלחה', { variant: 'success' });
      }
      onSuccess();
    } catch (err) {
      enqueueSnackbar(err instanceof Error ? err.message : 'שגיאה בשמירת התרגיל', { variant: 'error' });
    } finally {
      setLoading(false);
    }
  };

  // --- Content Editor Functions ---
  const addQuestion = () => setQuestions([...questions, { id: Date.now().toString(), question: '', options: ['', ''], type: 'multiple_choice', required: true }]);
  const removeQuestion = (index: number) => setQuestions(questions.filter((_, i) => i !== index));
  const updateQuestion = (index: number, field: keyof QuestionnaireQuestion, value: string | boolean | string[] | QuestionOption[]) => {
    const updated = [...questions];
    updated[index] = { ...updated[index], [field]: value };
    setQuestions(updated);
  };
  
  const addActionPlanField = () => setActionPlanFields([...actionPlanFields, { name: `field_${Date.now()}`, label: '', placeholder: '', required: false, type: 'text_input' }]);
  const removeActionPlanField = (index: number) => setActionPlanFields(actionPlanFields.filter((_, i) => i !== index));
  const updateActionPlanField = (index: number, field: keyof ActionPlanField, value: string | boolean) => {
    const updated = [...actionPlanFields];
    updated[index] = { ...updated[index], [field]: value };
    setActionPlanFields(updated);
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>{exercise ? 'עריכת תרגיל' : 'יצירת תרגיל חדש'}</DialogTitle>
      <DialogContent>
        <Box sx={{ p: 2, display: 'flex', flexDirection: 'column', gap: 2 }}>
          {/* Basic Info */}
          <FormControl fullWidth>
            <InputLabel id="exercise-type-label">סוג התרגיל</InputLabel>
            <Select
              labelId="exercise-type-label"
              value={formData.type}
              label="סוג התרגיל"
              onChange={(e) => setFormData({ ...formData, type: e.target.value as ExerciseType })}
            >
              {EXERCISE_TYPES.map((type) => (
                <MenuItem key={type.value} value={type.value}>
                  {type.label}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <TextField
            fullWidth
            label="כותרת התרגיל"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            required
          />

          <TextField
            fullWidth
            multiline
            rows={2}
            label="תיאור"
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
          />
          
          {/* Settings */}
          <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 2 }}>
            <TextField
              type="number"
              label="ניקוד"
              value={formData.points}
              onChange={(e) => setFormData({ ...formData, points: parseInt(e.target.value) || 0 })}
              inputProps={{ min: 0 }}
            />
            
            <TextField
              type="number"
              label="סדר תצוגה"
              value={formData.order}
              onChange={(e) => setFormData({ ...formData, order: parseInt(e.target.value) || 0 })}
              inputProps={{ min: 0 }}
            />
            
            <TextField
              type="number"
              label="מגבלת זמן (דקות)"
              value={formData.timeLimit ? Math.floor(formData.timeLimit / 60) : 0}
              onChange={(e) => setFormData({ ...formData, timeLimit: (parseInt(e.target.value) || 0) * 60 })}
              inputProps={{ min: 0 }}
              helperText="0 = ללא הגבלה"
            />
          </Box>

          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            <FormControlLabel
              control={
                <Switch
                  checked={formData.required}
                  onChange={(e) => setFormData({ ...formData, required: e.target.checked })}
                />
              }
              label="תרגיל חובה"
            />
            
            <FormControlLabel
              control={
                <Switch
                  checked={formData.allowRetake}
                  onChange={(e) => setFormData({ ...formData, allowRetake: e.target.checked })}
                />
              }
              label="אפשר ביצוע חוזר"
            />
            
            {formData.type === 'questionnaire' && (
              <FormControlLabel
                control={
                  <Switch
                    checked={formData.showCorrectAnswers}
                    onChange={(e) => setFormData({ ...formData, showCorrectAnswers: e.target.checked })}
                  />
                }
                label="הצג תשובות נכונות"
              />
            )}
          </Box>
          
          {/* Content editor based on type */}
          <Box sx={{ mt: 2, p: 2, border: '1px solid #ddd', borderRadius: 1 }}>
            <ExerciseContentEditor
              type={formData.type}
              questions={questions}
              updateQuestion={updateQuestion}
              removeQuestion={removeQuestion}
              addQuestion={addQuestion}
              actionPlanFields={actionPlanFields}
              updateActionPlanField={updateActionPlanField}
              removeActionPlanField={removeActionPlanField}
              addActionPlanField={addActionPlanField}
              instructions={instructions}
              setInstructions={setInstructions}
              reflectionQuestion={reflectionQuestion}
              setReflectionQuestion={setReflectionQuestion}
            />
          </Box>
        </Box>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} color="inherit">ביטול</Button>
        <Button onClick={handleSave} color="primary" variant="contained" disabled={loading}>
          {exercise ? 'שמור שינויים' : 'צור תרגיל'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default ExerciseDialog; 