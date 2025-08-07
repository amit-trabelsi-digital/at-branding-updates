import React, { useState } from 'react';
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragEndEvent,
} from '@dnd-kit/core';
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import {
  useSortable,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import {
  Box,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Typography,
  IconButton,
  Tooltip,
  Chip,
  Alert,
  CircularProgress,
} from '@mui/material';
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
  DragIndicator as DragIcon,
  Warning as WarningIcon,
} from '@mui/icons-material';
import { Lesson } from '../../utils/types';
import { updateLessonsOrder } from '../../services/coursesApi';
import { useSnackbar } from 'notistack';

interface SortableRowProps {
  lesson: Lesson;
  onEdit: (lesson: Lesson) => void;
  onDelete: (lesson: Lesson) => void;
}

const SortableRow: React.FC<SortableRowProps> = ({ lesson, onEdit, onDelete }) => {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: lesson._id || lesson.id! });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  };

  return (
    <TableRow
      ref={setNodeRef}
      style={style}
      sx={{
        backgroundColor: isDragging ? '#f0f0f0' : 'transparent',
        '&:hover': {
          backgroundColor: '#f5f5f5',
        },
      }}
    >
      <TableCell sx={{ width: '40px', padding: '6px 8px' }}>
        <IconButton
          {...attributes}
          {...listeners}
          size="small"
          sx={{
            cursor: 'grab',
            padding: '4px',
            '&:active': {
              cursor: 'grabbing',
            },
          }}
        >
          <DragIcon fontSize="small" />
        </IconButton>
      </TableCell>
      <TableCell sx={{ padding: '6px 8px' }}>
        <Typography variant="body2" sx={{ fontWeight: 'bold', fontSize: '0.7rem' }}>
          {lesson.lessonNumber || lesson.order}
        </Typography>
      </TableCell>
      <TableCell sx={{ padding: '6px 8px' }}>
        <Typography variant="body2" sx={{ fontWeight: 'medium', fontSize: '0.7rem' }}>
          {lesson.title}
        </Typography>
        {lesson.shortTitle && (
          <Typography variant="caption" color="text.secondary" sx={{ fontSize: '0.6rem' }}>
            {lesson.shortTitle}
          </Typography>
        )}
      </TableCell>
      <TableCell sx={{ padding: '6px 8px' }}>
        <Typography variant="body2" color="text.secondary" sx={{ fontSize: '0.7rem' }}>
          {lesson.description}
        </Typography>
      </TableCell>
      <TableCell sx={{ padding: '6px 8px' }}>
        <Typography variant="body2" sx={{ fontSize: '0.7rem' }}>
          {lesson.duration} דקות
        </Typography>
      </TableCell>
      <TableCell sx={{ padding: '6px 8px' }}>
        <Typography variant="body2" sx={{ fontSize: '0.7rem' }}>
          {lesson.exercises?.length || 0} תרגילים
        </Typography>
      </TableCell>
      <TableCell sx={{ padding: '6px 8px' }}>
        <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
          {lesson.isPublished ? (
            <Chip label="פורסם" size="small" color="success" sx={{ fontSize: '0.65rem', height: '20px' }} />
          ) : (
            <Chip label="טיוטה" size="small" color="default" sx={{ fontSize: '0.65rem', height: '20px' }} />
          )}
          {lesson.contentStatus?.hasContent === false && (
            <Tooltip title="אין תוכן">
              <WarningIcon color="warning" fontSize="small" />
            </Tooltip>
          )}
        </Box>
      </TableCell>
      <TableCell sx={{ padding: '6px 8px' }}>
        <Box sx={{ display: 'flex', gap: 1 }}>
          <Tooltip title="ערוך שיעור">
            <IconButton
              onClick={() => onEdit(lesson)}
              size="small"
              sx={{ padding: '4px' }}
            >
              <EditIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title="מחק שיעור">
            <IconButton
              onClick={() => onDelete(lesson)}
              size="small"
              color="error"
              sx={{ padding: '4px' }}
            >
              <DeleteIcon fontSize="small" />
            </IconButton>
          </Tooltip>
        </Box>
      </TableCell>
    </TableRow>
  );
};

interface SortableLessonsListProps {
  lessons: Lesson[];
  programId: string;
  loading?: boolean;
  onEdit: (lesson: Lesson) => void;
  onDelete: (lesson: Lesson) => void;
  onOrderChanged: () => void;
}

const SortableLessonsList: React.FC<SortableLessonsListProps> = ({
  lessons,
  programId,
  loading = false,
  onEdit,
  onDelete,
  onOrderChanged,
}) => {
  const [isUpdating, setIsUpdating] = useState(false);
  const { enqueueSnackbar } = useSnackbar();

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  const handleDragEnd = async (event: DragEndEvent) => {
    const { active, over } = event;

    if (!over || active.id === over.id) {
      return;
    }

    const oldIndex = lessons.findIndex((lesson) => (lesson._id || lesson.id!) === active.id);
    const newIndex = lessons.findIndex((lesson) => (lesson._id || lesson.id!) === over.id);

    if (oldIndex === -1 || newIndex === -1) {
      return;
    }

    const newLessons = arrayMove(lessons, oldIndex, newIndex);
    
    // יצירת מערך עדכונים
    const lessonsOrder = newLessons.map((lesson, index) => ({
      lessonId: lesson._id || lesson.id!,
      order: index + 1,
    }));

    try {
      setIsUpdating(true);
      await updateLessonsOrder(programId, lessonsOrder);
      onOrderChanged();
      enqueueSnackbar('סדר השיעורים עודכן בהצלחה', { variant: 'success' });
    } catch (error) {
      console.error('Error updating lessons order:', error);
      enqueueSnackbar('שגיאה בעדכון סדר השיעורים', { variant: 'error' });
    } finally {
      setIsUpdating(false);
    }
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
        <CircularProgress />
        <Typography sx={{ ml: 2, fontSize: '0.7rem' }}>טוען שיעורים...</Typography>
      </Box>
    );
  }

  if (!lessons || lessons.length === 0) {
    return (
      <Alert severity="info" sx={{ mb: 2 }}>
        <Typography variant="body2" sx={{ fontSize: '0.7rem' }}>
          אין שיעורים בתוכנית זו
        </Typography>
      </Alert>
    );
  }

  // מיון השיעורים לפי סדר
  const sortedLessons = [...lessons].sort((a, b) => (a.order || 0) - (b.order || 0));

  return (
    <Box sx={{ position: 'relative' }}>
      {isUpdating && (
        <Box
          sx={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(255, 255, 255, 0.8)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1000,
            borderRadius: 1,
          }}
        >
          <CircularProgress size={24} />
          <Typography sx={{ ml: 2, fontSize: '0.7rem' }}>מעדכן סדר...</Typography>
        </Box>
      )}

      <Box sx={{ mb: 2 }}>
        <Alert severity="info" sx={{ mb: 2 }}>
          <Typography variant="body2" sx={{ fontSize: '0.7rem' }}>
            גרור את השיעורים לשינוי סדרם. השינויים יישמרו אוטומטית.
          </Typography>
        </Alert>
      </Box>

      <DndContext
        sensors={sensors}
        collisionDetection={closestCenter}
        onDragEnd={handleDragEnd}
      >
        <SortableContext
          items={sortedLessons.map((lesson) => lesson._id || lesson.id!)}
          strategy={verticalListSortingStrategy}
        >
          <TableContainer component={Paper}>
            <Table sx={{ '& .MuiTableCell-root': { padding: '6px 8px', fontSize: '0.7rem' } }}>
              <TableHead>
                <TableRow>
                  <TableCell sx={{ width: '40px', fontSize: '0.7rem', fontWeight: 'bold', padding: '6px 8px' }}></TableCell>
                  <TableCell sx={{ fontSize: '0.7rem', fontWeight: 'bold', padding: '6px 8px' }}>מספר</TableCell>
                  <TableCell sx={{ fontSize: '0.7rem', fontWeight: 'bold', padding: '6px 8px' }}>שם השיעור</TableCell>
                  <TableCell sx={{ fontSize: '0.7rem', fontWeight: 'bold', padding: '6px 8px' }}>תיאור</TableCell>
                  <TableCell sx={{ fontSize: '0.7rem', fontWeight: 'bold', padding: '6px 8px' }}>משך (דקות)</TableCell>
                  <TableCell sx={{ fontSize: '0.7rem', fontWeight: 'bold', padding: '6px 8px' }}>תרגילים</TableCell>
                  <TableCell sx={{ fontSize: '0.7rem', fontWeight: 'bold', padding: '6px 8px' }}>סטטוס</TableCell>
                  <TableCell sx={{ fontSize: '0.7rem', fontWeight: 'bold', padding: '6px 8px' }}>פעולות</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {sortedLessons.map((lesson) => (
                  <SortableRow
                    key={lesson._id || lesson.id!}
                    lesson={lesson}
                    onEdit={onEdit}
                    onDelete={onDelete}
                  />
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </SortableContext>
      </DndContext>
    </Box>
  );
};

export default SortableLessonsList;

// Credit: Developed by Amit Trabelsi - https://amit-trabelsi.co.il 