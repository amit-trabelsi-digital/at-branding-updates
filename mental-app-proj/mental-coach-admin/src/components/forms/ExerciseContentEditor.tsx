import React from 'react';
import { Box, Button, TextField, Switch, FormControlLabel, IconButton, Typography } from '@mui/material';
import { Add as AddIcon, Delete as DeleteIcon } from '@mui/icons-material';
import { ExerciseType, QuestionnaireQuestion, ActionPlanField, QuestionOption } from '../../utils/types';

interface Props {
  type: ExerciseType;
  questions: QuestionnaireQuestion[];
  updateQuestion: (index: number, field: keyof QuestionnaireQuestion, value: string | boolean | string[] | QuestionOption[]) => void;
  removeQuestion: (index: number) => void;
  addQuestion: () => void;
  actionPlanFields: ActionPlanField[];
  updateActionPlanField: (index: number, field: keyof ActionPlanField, value: string | boolean) => void;
  removeActionPlanField: (index: number) => void;
  addActionPlanField: () => void;
  instructions: string[];
  setInstructions: (instructions: string[]) => void;
  reflectionQuestion: string;
  setReflectionQuestion: (question: string) => void;
}

const ExerciseContentEditor: React.FC<Props> = ({
  type,
  questions,
  updateQuestion,
  removeQuestion,
  addQuestion,
  actionPlanFields,
  updateActionPlanField,
  removeActionPlanField,
  addActionPlanField,
  instructions,
  setInstructions,
  reflectionQuestion,
  setReflectionQuestion,
}) => {
  switch (type) {
    case 'questionnaire':
      return (
        <Box>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant="subtitle1">שאלות</Typography>
            <Button size="small" startIcon={<AddIcon />} onClick={addQuestion}>
              הוסף שאלה
            </Button>
          </Box>
          {questions.map((question, index) => (
            <Box key={question.id} sx={{ mb: 3, p: 2, border: '1px solid #e0e0e0', borderRadius: 1 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
                <Typography variant="subtitle2">שאלה {index + 1}</Typography>
                <IconButton size="small" onClick={() => removeQuestion(index)}>
                  <DeleteIcon />
                </IconButton>
              </Box>
              <TextField
                fullWidth
                label="נוסח השאלה"
                value={question.question}
                onChange={(e) => updateQuestion(index, 'question', e.target.value)}
                sx={{ mb: 2 }}
              />
              <Typography variant="caption" sx={{ display: 'block', mb: 1 }}>אפשרויות:</Typography>
              {(question.options || []).map((option, optIndex) => {
                // Handle both string[] and QuestionOption[]
                const optionText = typeof option === 'string' ? option : option.text;
                return (
                  <TextField
                    key={optIndex}
                    fullWidth
                    size="small"
                    label={`אפשרות ${optIndex + 1}`}
                    value={optionText}
                    onChange={(e) => {
                      const newOptions = [...(question.options || [])];
                      if (typeof newOptions[optIndex] === 'string') {
                        newOptions[optIndex] = e.target.value;
                      } else {
                        newOptions[optIndex] = { ...newOptions[optIndex] as QuestionOption, text: e.target.value };
                      }
                      const finalOptions: QuestionOption[] = newOptions.map(opt => typeof opt === 'string' ? { text: opt } : opt);
                      updateQuestion(index, 'options', finalOptions);
                    }}
                    sx={{ mb: 1 }}
                  />
                );
              })}
              <Box sx={{ display: 'flex', gap: 1, mt: 1 }}>
                <Button
                  size="small"
                  onClick={() => {
                    const currentOptions = question.options || [];
                    const newOption = typeof currentOptions[0] === 'string' ? '' : { text: '', isCorrect: false };
                    const newOptions = [...currentOptions, newOption];
                    const finalOptions: QuestionOption[] = newOptions.map(opt => typeof opt === 'string' ? { text: opt } : opt);
                    updateQuestion(index, 'options', finalOptions);
                  }}
                >
                  הוסף אפשרות
                </Button>
                {(question.options?.length || 0) > 2 && (
                  <Button
                    size="small"
                    color="error"
                    onClick={() => {
                      const newOptions = (question.options || []).slice(0, -1);
                      updateQuestion(index, 'options', newOptions);
                    }}
                  >
                    הסר אחרונה
                  </Button>
                )}
              </Box>
              <FormControlLabel
                control={
                  <Switch
                    checked={question.required}
                    onChange={(e) => updateQuestion(index, 'required', e.target.checked)}
                  />
                }
                label="שאלה חובה"
                sx={{ mt: 2 }}
              />
            </Box>
          ))}
        </Box>
      );
    
    case 'text_input':
      return (
        <Box>
          <Typography variant="subtitle1" sx={{ mb: 2 }}>שאלות לתשובה חופשית</Typography>
          <Box sx={{ mb: 2 }}>
            {instructions.map((instruction, index) => (
              <TextField
                key={index}
                fullWidth
                multiline
                rows={2}
                label={`שאלה ${index + 1}`}
                value={instruction}
                onChange={(e) => {
                  const newInstructions = [...instructions];
                  newInstructions[index] = e.target.value;
                  setInstructions(newInstructions);
                }}
                sx={{ mb: 2 }}
              />
            ))}
          </Box>
          <Box sx={{ display: 'flex', gap: 1 }}>
            <Button
              size="small"
              startIcon={<AddIcon />}
              onClick={() => setInstructions([...instructions, ''])}
            >
              הוסף שאלה
            </Button>
            {instructions.length > 1 && (
              <Button
                size="small"
                color="error"
                onClick={() => setInstructions(instructions.slice(0, -1))}
              >
                הסר אחרונה
              </Button>
            )}
          </Box>
        </Box>
      );
    
    case 'action_plan':
      return (
        <Box>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant="subtitle1">שדות תוכנית פעולה</Typography>
            <Button size="small" startIcon={<AddIcon />} onClick={addActionPlanField}>
              הוסף שדה
            </Button>
          </Box>
          {actionPlanFields.map((field, index) => (
            <Box key={field.name} sx={{ mb: 2, p: 2, border: '1px solid #e0e0e0', borderRadius: 1 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
                <Typography variant="subtitle2">שדה {index + 1}</Typography>
                <IconButton size="small" onClick={() => removeActionPlanField(index)}>
                  <DeleteIcon />
                </IconButton>
              </Box>
              <TextField
                fullWidth
                label="תווית השדה"
                value={field.label}
                onChange={(e) => updateActionPlanField(index, 'label', e.target.value)}
                sx={{ mb: 2 }}
              />
              <TextField
                fullWidth
                label="טקסט עזר"
                value={field.placeholder}
                onChange={(e) => updateActionPlanField(index, 'placeholder', e.target.value)}
                sx={{ mb: 2 }}
              />
              <FormControlLabel
                control={
                  <Switch
                    checked={field.required}
                    onChange={(e) => updateActionPlanField(index, 'required', e.target.checked)}
                  />
                }
                label="שדה חובה"
              />
            </Box>
          ))}
        </Box>
      );
    
    case 'video_reflection':
      return (
        <Box>
          <Typography variant="subtitle1" sx={{ mb: 2 }}>רפלקציה על וידאו</Typography>
          <TextField
            fullWidth
            multiline
            rows={3}
            label="שאלת רפלקציה"
            value={reflectionQuestion}
            onChange={(e) => setReflectionQuestion(e.target.value)}
            placeholder="למשל: איך הרגשת במהלך הצפייה? מה למדת?"
          />
          <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
            השאלה תוצג למשתמש לאחר צפייה בוידאו
          </Typography>
        </Box>
      );
    
    case 'mental_visualization':
      return (
        <Box>
          <Typography variant="subtitle1" sx={{ mb: 2 }}>תרגיל ויזואליזציה מנטלית</Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            הגדר את השלבים והוראות התרגיל
          </Typography>
          {instructions.map((instruction, index) => (
            <TextField
              key={index}
              fullWidth
              multiline
              rows={2}
              label={`שלב ${index + 1}`}
              value={instruction}
              onChange={(e) => {
                const newInstructions = [...instructions];
                newInstructions[index] = e.target.value;
                setInstructions(newInstructions);
              }}
              sx={{ mb: 2 }}
            />
          ))}
          <Box sx={{ display: 'flex', gap: 1 }}>
            <Button
              size="small"
              startIcon={<AddIcon />}
              onClick={() => setInstructions([...instructions, ''])}
            >
              הוסף שלב
            </Button>
            {instructions.length > 1 && (
              <Button
                size="small"
                color="error"
                onClick={() => setInstructions(instructions.slice(0, -1))}
              >
                הסר אחרון
              </Button>
            )}
          </Box>
        </Box>
      );
    
    case 'content_slider':
      return (
        <Box>
          <Typography variant="subtitle1" sx={{ mb: 2 }}>סליידר תוכן אינטראקטיבי</Typography>
          <Typography variant="body2" color="text.secondary">
            תכונה זו בפיתוח - ניתן יהיה להוסיף תוכן אינטראקטיבי עם מעברים
          </Typography>
        </Box>
      );
    
    case 'file_upload':
      return (
        <Box>
          <Typography variant="subtitle1" sx={{ mb: 2 }}>העלאת קובץ</Typography>
          <TextField
            fullWidth
            label="הוראות להעלאת קובץ"
            value={instructions[0] || ''}
            onChange={(e) => setInstructions([e.target.value])}
            multiline
            rows={2}
            placeholder="למשל: העלה הקלטה של עצמך מתרגל את הטכניקה"
          />
          <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
            המשתמש יוכל להעלות קובץ (אודיו/וידאו/תמונה)
          </Typography>
        </Box>
      );
    
    case 'signature':
      return (
        <Box>
          <Typography variant="subtitle1" sx={{ mb: 2 }}>חתימה דיגיטלית</Typography>
          <TextField
            fullWidth
            label="טקסט להצגה לפני החתימה"
            value={instructions[0] || ''}
            onChange={(e) => setInstructions([e.target.value])}
            multiline
            rows={3}
            placeholder="למשל: אני מתחייב לתרגל את הטכניקות שלמדתי..."
          />
          <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
            המשתמש יתבקש לחתום דיגיטלית על המסך
          </Typography>
        </Box>
      );
    
    default:
      return (
        <Typography color="error">סוג תרגיל לא מוכר</Typography>
      );
  }
};

export default ExerciseContentEditor; 