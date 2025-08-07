import { useState, useEffect, useCallback } from 'react';
import { Box, IconButton, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, TextField, Button, Drawer, Alert, Typography, Tooltip, Chip } from '@mui/material';
import { Delete as DeleteIcon, Edit as EditIcon, Add as AddIcon, Warning as WarningIcon } from '@mui/icons-material';
import { useSnackbar } from 'notistack';
import AppButton from '../../components/general/AppButton';
import AppTitle from '../../components/general/AppTitle';
import AppLoadingScreen from '../../components/general/AppLoadingScreen';
import TrainingProgramDialog from '../../components/dialogs/TrainingProgramDialog';
import LessonEditDrawer from '../../components/drawers/LessonEditDrawer';
import ConfirmDialog from '../../components/dialogs/ConfirmDialog';
import SortableLessonsList from '../../components/general/SortableLessonsList';
import { TrainingProgram, Lesson } from '../../utils/types';
import { getTrainingPrograms, deleteTrainingProgram, deleteLesson, getLessonsByProgram, getExercisesByLesson } from '../../services/coursesApi';
import { appConfig } from '../../data/config';
import useDialog from '../../hooks/useDialog';

export const TrainingProgramsPage = () => {
  const [programs, setPrograms] = useState<TrainingProgram[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedStatus, setSelectedStatus] = useState('all');
  const [selectedProgram, setSelectedProgram] = useState<TrainingProgram | null>(null);
  const [selectedLesson, setSelectedLesson] = useState<Lesson | null>(null);
  const [programLessons, setProgramLessons] = useState<Lesson[]>([]);
  const [lessonsLoading, setLessonsLoading] = useState(false);
  const { enqueueSnackbar } = useSnackbar();

  const { open: isProgramDialogOpen, openDialog: openProgramDialog, closeDialog: closeProgramDialog } = useDialog();
  const { open: isLessonDialogOpen, openDialog: openLessonDialog, closeDialog: closeLessonDialog } = useDialog();
  const { open: isConfirmOpen, openDialog: openConfirm, closeDialog: closeConfirm } = useDialog();
  const { open: isDrawerOpen, openDialog: openDrawer, closeDialog: closeDrawer } = useDialog();

  const fetchPrograms = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await getTrainingPrograms({
        status: selectedStatus,
        searchTerm: searchTerm,
      });
      
      // הפונקציה getTrainingPrograms כבר מטפלת בפורמטים השונים ומחזירה תמיד מערך
      setPrograms(data);
    } catch (err) {
      console.error('Error in fetchPrograms:', err);
      const errorMessage = err instanceof Error ? err.message : 'שגיאה בטעינת תוכניות האימון';
      
      // אם זו שגיאת רשת, נציג הודעה מתאימה
      if (errorMessage.includes('Failed to fetch') || errorMessage.includes('Network')) {
        setError('לא ניתן להתחבר לשרת. אנא בדוק את החיבור לאינטרנט ונסה שוב.');
      } else {
        setError(errorMessage);
      }
      setPrograms([]);
    } finally {
      setLoading(false);
    }
  }, [selectedStatus, searchTerm]);

  useEffect(() => {
    fetchPrograms();
  }, [fetchPrograms]);

  const fetchLessons = useCallback(async (programId: string) => {
    try {
      setLessonsLoading(true);
      const lessons = await getLessonsByProgram(programId);
      // וידוא שהנתונים הם מערך
      const safeLessons = Array.isArray(lessons) ? lessons : [];
      
      // טעינת תרגילים לכל שיעור
      const lessonsWithExercises = await Promise.all(
        safeLessons.map(async (lesson) => {
          try {
            const exercises = await getExercisesByLesson(lesson._id || lesson.id!);
            return { ...lesson, exercises };
          } catch (exerciseError) {
            console.error(`Error fetching exercises for lesson ${lesson._id}:`, exerciseError);
            return { ...lesson, exercises: [] };
          }
        })
      );
      
      setProgramLessons(lessonsWithExercises);
    } catch (err) {
      console.error('Error fetching lessons:', err);
      enqueueSnackbar('שגיאה בטעינת השיעורים', { variant: 'error' });
      setProgramLessons([]);
    } finally {
      setLessonsLoading(false);
    }
  }, [enqueueSnackbar]);

  const handleDeleteProgram = async (program: TrainingProgram) => {
    try {
      await deleteTrainingProgram(program.id || program._id || '');
      await fetchPrograms();
      closeConfirm();
      enqueueSnackbar('התוכנית נמחקה בהצלחה', { variant: 'success' });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'שגיאה במחיקת תוכנית האימון');
      enqueueSnackbar('שגיאה במחיקת התוכנית', { variant: 'error' });
    }
  };

  const handleDeleteLesson = async (programId: string, lessonId: string) => {
    try {
      await deleteLesson(programId, lessonId);
      await fetchPrograms();
      await fetchLessons(programId);
      closeConfirm();
      enqueueSnackbar('השיעור נמחק בהצלחה', { variant: 'success' });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'שגיאה במחיקת השיעור');
      enqueueSnackbar('שגיאה במחיקת השיעור', { variant: 'error' });
    }
  };

  const handleProgramSuccess = async () => {
    await fetchPrograms();
    closeProgramDialog();
    enqueueSnackbar('התוכנית נשמרה בהצלחה', { variant: 'success' });
  };

  const handleLessonSuccess = async () => {
    await fetchPrograms();
    if (selectedProgram) {
      await fetchLessons(selectedProgram.id || selectedProgram._id || '');
    }
    closeLessonDialog();
    enqueueSnackbar('השיעור נשמר בהצלחה', { variant: 'success' });
  };

  const getErrorMessage = (error: string) => {
    if (error.includes('401') || error.includes('Unauthorized')) {
      return {
        title: 'נדרש אימות למערכת',
        message: 'אנא התחבר למערכת או פנה למנהל המערכת לקבלת הרשאות.',
        contact: `לפנייה: ${appConfig.supportEmail} או ${appConfig.supportPhone}`
      };
    }
    
    if (error.includes('404') || error.includes('Not Found')) {
      return {
        title: 'השירות אינו זמין',
        message: 'השרת אינו זמין כעת או שהשירות לא הוגדר עדיין.',
        contact: `לפנייה: ${appConfig.supportEmail} או ${appConfig.supportPhone}`
      };
    }
    
    if (error.includes('500') || error.includes('502') || error.includes('503') || error.includes('Internal Server Error')) {
      return {
        title: 'שגיאת שרת',
        message: 'יש בעיה זמנית בשרת. אנא נסה שוב מאוחר יותר.',
        contact: `אם הבעיה נמשכת, פנה אלינו: ${appConfig.supportEmail} או ${appConfig.supportPhone}`
      };
    }
    
    if (error.includes('Failed to fetch') || error.includes('Network') || error.includes('ECONNREFUSED')) {
      return {
        title: 'בעיית חיבור',
        message: 'אין חיבור לאינטרנט או שהשרת אינו זמין. אנא בדוק את החיבור שלך ונסה שוב.',
        contact: `לפנייה: ${appConfig.supportEmail} או ${appConfig.supportPhone}`
      };
    }
    
    return {
      title: 'שגיאה לא צפויה',
      message: error,
      contact: `לפנייה: ${appConfig.supportEmail} או ${appConfig.supportPhone}`
    };
  };

  if (loading) {
    return <AppLoadingScreen />;
  }

  const safePrograms = Array.isArray(programs) ? programs : [];

  return (
    <Box p={3}>
      <AppTitle title="תוכניות אימון" />

      <Box display="flex" gap={2} mb={3}>
        <TextField
          label="חיפוש"
          variant="outlined"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          sx={{ width: 200 }}
        />
        <TextField
          select
          label="סטטוס"
          value={selectedStatus}
          onChange={(e) => setSelectedStatus(e.target.value)}
          sx={{ width: 200 }}
          slotProps={{
            select: {
              native: true,
            },
          }}
        >
          <option value="all">הכל</option>
          <option value="active">פעיל</option>
          <option value="draft">טיוטה</option>
          <option value="archived">בארכיון</option>
        </TextField>
        <AppButton 
          _label="תוכנית חדשה"
          onClick={() => {
            setSelectedProgram(null);
            openProgramDialog();
          }}
        />
      </Box>

      {error && (
        <Alert 
          severity="error" 
          icon={<WarningIcon />}
          sx={{ mb: 3, textAlign: 'right' }}
          action={
            <Button 
              color="inherit" 
              size="small" 
              onClick={fetchPrograms}
              disabled={loading}
            >
              נסה שוב
            </Button>
          }
        >
          <Typography variant="h6" gutterBottom>
            {getErrorMessage(error).title}
          </Typography>
          <Typography variant="body1" gutterBottom>
            {getErrorMessage(error).message}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            {getErrorMessage(error).contact}
          </Typography>
        </Alert>
      )}

      {!error && !loading && safePrograms.length === 0 && (
        <Alert 
          severity="info" 
          sx={{ mb: 3, textAlign: 'right' }}
          action={
            <Button 
              color="primary" 
              size="small" 
              onClick={() => {
                setSelectedProgram(null);
                openProgramDialog();
              }}
            >
              צור תוכנית ראשונה
            </Button>
          }
        >
          <Typography variant="body1">
            אין תוכניות אימון במערכת כעת.
          </Typography>
          <Typography variant="body2" color="text.secondary">
            {searchTerm || selectedStatus !== 'all' 
              ? 'נסה לשנות את הפילטרים או ליצור תוכנית חדשה.'
              : 'לחץ על "צור תוכנית ראשונה" כדי להתחיל.'
            }
          </Typography>
        </Alert>
      )}

      {!error && safePrograms.length > 0 && (
        <>
          <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
            <Typography variant="body2" color="text.secondary">
              נמצאו {safePrograms.length} תוכניות אימון
            </Typography>
          </Box>
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>שם התוכנית</TableCell>
                  <TableCell>תיאור</TableCell>
                  <TableCell>סטטוס</TableCell>
                  <TableCell>שיעורים</TableCell>
                  <TableCell>פעולות</TableCell>
                </TableRow>
              </TableHead>
            <TableBody>
              {safePrograms.map((program) => (
                <TableRow 
                  key={program.id || program._id} 
                  hover 
                  onClick={() => {
                    setSelectedProgram(program);
                    fetchLessons(program.id || program._id || '');
                    openDrawer();
                  }}
                  sx={{ cursor: 'pointer' }}
                >
                  <TableCell>{program.title}</TableCell>
                  <TableCell>{program.description}</TableCell>
                  <TableCell>
                    <Box
                      sx={{
                        px: 1,
                        py: 0.5,
                        borderRadius: 1,
                        fontSize: '0.75rem',
                        fontWeight: 'medium',
                        backgroundColor: 
                          program.status === 'active' ? 'success.light' :
                          program.status === 'draft' ? 'warning.light' : 'grey.300',
                        color: 
                          program.status === 'active' ? 'success.dark' :
                          program.status === 'draft' ? 'warning.dark' : 'text.secondary'
                      }}
                    >
                      {program.status === 'active' ? 'פעיל' :
                       program.status === 'draft' ? 'טיוטה' : 
                       program.status === 'archived' ? 'בארכיון' : program.status}
                    </Box>
                  </TableCell>
                  <TableCell>{program.totalLessons || 0}</TableCell>
                  <TableCell>
                    <Tooltip title="עריכת תוכנית">
                      <IconButton
                        onClick={(e) => {
                          e.stopPropagation();
                          setSelectedProgram(program);
                          openProgramDialog();
                        }}
                      >
                        <EditIcon />
                      </IconButton>
                    </Tooltip>
                    <Tooltip title="מחיקת תוכנית">
                      <IconButton
                        onClick={(e) => {
                          e.stopPropagation();
                          setSelectedProgram(program);
                          openConfirm();
                        }}
                      >
                        <DeleteIcon />
                      </IconButton>
                    </Tooltip>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
        </>
      )}

      {isProgramDialogOpen && (
        <TrainingProgramDialog
          open={isProgramDialogOpen}
          onClose={closeProgramDialog}
          program={selectedProgram}
          onSuccess={handleProgramSuccess}
        />
      )}

      {isLessonDialogOpen && selectedProgram && (
        <LessonEditDrawer
          open={isLessonDialogOpen}
          onClose={closeLessonDialog}
          programId={selectedProgram.id || selectedProgram._id || ''}
          lesson={selectedLesson}
          onSuccess={handleLessonSuccess}
        />
      )}

      {isConfirmOpen && selectedProgram && (
        <ConfirmDialog
          open={isConfirmOpen}
          onClose={closeConfirm}
          title={selectedLesson ? "מחיקת שיעור" : "מחיקת תוכנית אימון"}
          content={
            selectedLesson 
              ? `האם אתה בטוח שברצונך למחוק את השיעור "${selectedLesson.title}"?`
              : `האם אתה בטוח שברצונך למחוק את התוכנית "${selectedProgram.title}"?`
          }
          onConfirm={() => {
            if (selectedLesson && selectedProgram) {
              handleDeleteLesson(selectedProgram.id || selectedProgram._id || '', selectedLesson.id || selectedLesson._id || '');
            } else if (selectedProgram){
              handleDeleteProgram(selectedProgram);
            }
          }}
        />
      )}

      <Drawer
        anchor="right"
        open={isDrawerOpen}
        onClose={closeDrawer}
        PaperProps={{
          sx: { 
            width: '50%',
            '& .MuiTypography-root': {
              fontSize: '0.75rem',
            },
            '& .MuiTypography-h6': {
              fontSize: '1rem',
            },
            '& .MuiButton-root': {
              fontSize: '0.75rem',
            },
            '& .MuiTableCell-root': {
              fontSize: '0.7rem',
              padding: '6px 8px',
            },
            '& .MuiChip-root': {
              fontSize: '0.65rem',
              height: '20px',
            },
            '& .MuiIconButton-root': {
              padding: '4px',
            }
          },
        }}
      >
        {selectedProgram && (
          <Box p={3}>
            <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
              <Typography variant="h6" sx={{ fontSize: '1rem', fontWeight: 'bold' }}>
                {selectedProgram.title}
              </Typography>
              <IconButton
                onClick={() => {
                  setSelectedProgram(selectedProgram);
                  openProgramDialog();
                }}
                title="ערוך פרטי תוכנית"
              >
                <EditIcon />
              </IconButton>
            </Box>

            {/* פרטי התוכנית */}
            <Paper sx={{ p: 2, mb: 3, backgroundColor: '#f5f5f5' }}>
              <Typography variant="subtitle2" sx={{ fontWeight: 'bold', mb: 1 }}>
                פרטי התוכנית
              </Typography>
              <Box sx={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 1 }}>
                <Typography variant="body2">
                  <strong>תיאור:</strong> {selectedProgram.description}
                </Typography>
                <Typography variant="body2">
                  <strong>קטגוריה:</strong> {selectedProgram.category === 'mental' ? 'מנטלי' :
                                         selectedProgram.category === 'technical' ? 'טכני' :
                                         selectedProgram.category === 'tactical' ? 'טקטי' :
                                         selectedProgram.category === 'physical' ? 'פיזי' :
                                         selectedProgram.category}
                </Typography>
                <Typography variant="body2">
                  <strong>סוג:</strong> {selectedProgram.type === 'course' ? 'קורס' : 
                                    selectedProgram.type === 'workshop' ? 'סדנה' : 
                                    selectedProgram.type}
                </Typography>
                <Typography variant="body2">
                  <strong>רמת קושי:</strong> {selectedProgram.difficulty === 'beginner' ? 'מתחילים' :
                                          selectedProgram.difficulty === 'intermediate' ? 'בינוני' :
                                          selectedProgram.difficulty === 'advanced' ? 'מתקדמים' :
                                          selectedProgram.difficulty === 'expert' ? 'מומחים' :
                                          selectedProgram.difficulty}
                </Typography>
                <Typography variant="body2">
                  <strong>משך משוער:</strong> {selectedProgram.estimatedDuration} דקות
                </Typography>
                <Typography variant="body2">
                  <strong>מספר שיעורים:</strong> {selectedProgram.totalLessons || programLessons.length}
                </Typography>
              </Box>
              {selectedProgram.tags && selectedProgram.tags.length > 0 && (
                <Box sx={{ mt: 1 }}>
                  <Typography variant="body2" sx={{ fontWeight: 'bold', mb: 0.5 }}>
                    תגיות:
                  </Typography>
                  <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                    {selectedProgram.tags.map((tag, index) => (
                      <Chip key={index} label={tag} size="small" variant="outlined" />
                    ))}
                  </Box>
                </Box>
              )}
            </Paper>

            {/* כותרת שיעורים */}
            <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
              <Typography variant="subtitle1" sx={{ fontSize: '0.9rem', fontWeight: 'bold' }}>
                שיעורים
              </Typography>
              <Button
                variant="contained"
                startIcon={<AddIcon />}
                onClick={() => {
                  setSelectedLesson(null);
                  openLessonDialog();
                }}
                sx={{ fontSize: '0.75rem' }}
              >
                שיעור חדש
              </Button>
            </Box>

            <SortableLessonsList
              lessons={programLessons}
              programId={selectedProgram.id || selectedProgram._id || ''}
              loading={lessonsLoading}
              onEdit={(lesson) => {
                setSelectedLesson(lesson);
                openLessonDialog();
              }}
              onDelete={(lesson) => {
                setSelectedLesson(lesson);
                openConfirm();
              }}
              onOrderChanged={() => {
                if (selectedProgram) {
                  fetchLessons(selectedProgram.id || selectedProgram._id || '');
                }
              }}
            />
          </Box>
        )}
      </Drawer>
    </Box>
  );
};

export default TrainingProgramsPage;
