import React, { useState, useEffect } from 'react';
import {
  Box,
  TextField,
  IconButton,
  Typography,
  Chip,
  Button,
  Alert,
} from '@mui/material';
import {
  Add as AddIcon,
  Delete as DeleteIcon,
  DragIndicator as DragIcon,
} from '@mui/icons-material';
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
  useSortable,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

interface HighlightItemProps {
  highlight: string;
  index: number;
  onUpdate: (index: number, value: string) => void;
  onDelete: (index: number) => void;
}

const HighlightItem: React.FC<HighlightItemProps> = ({
  highlight,
  index,
  onUpdate,
  onDelete,
}) => {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: `highlight-${index}` });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  };

  return (
    <Box
      ref={setNodeRef}
      style={style}
      sx={{
        display: 'flex',
        alignItems: 'center',
        gap: 1,
        mb: 1,
        p: 1,
        backgroundColor: isDragging ? '#f0f0f0' : 'transparent',
        borderRadius: 1,
        '&:hover': {
          backgroundColor: '#f5f5f5',
        },
      }}
    >
      <IconButton
        {...attributes}
        {...listeners}
        size="small"
        sx={{
          cursor: 'grab',
          '&:active': {
            cursor: 'grabbing',
          },
        }}
      >
        <DragIcon fontSize="small" />
      </IconButton>
      
      <TextField
        fullWidth
        size="small"
        value={highlight}
        onChange={(e) => onUpdate(index, e.target.value)}
        placeholder={`הדגש ${index + 1}`}
        sx={{ flex: 1 }}
      />
      
      <IconButton
        size="small"
        color="error"
        onClick={() => onDelete(index)}
      >
        <DeleteIcon fontSize="small" />
      </IconButton>
    </Box>
  );
};

interface HighlightsManagerProps {
  highlights: string[];
  onChange: (highlights: string[]) => void;
  label?: string;
  maxItems?: number;
}

const HighlightsManager: React.FC<HighlightsManagerProps> = ({
  highlights,
  onChange,
  label = 'הדגשים',
  maxItems = 10,
}) => {
  const [localHighlights, setLocalHighlights] = useState<string[]>(highlights || []);

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  useEffect(() => {
    setLocalHighlights(highlights || []);
  }, [highlights]);

  const handleAdd = () => {
    if (localHighlights.length < maxItems) {
      const newHighlights = [...localHighlights, ''];
      setLocalHighlights(newHighlights);
      onChange(newHighlights);
    }
  };

  const handleUpdate = (index: number, value: string) => {
    const newHighlights = [...localHighlights];
    newHighlights[index] = value;
    setLocalHighlights(newHighlights);
    onChange(newHighlights);
  };

  const handleDelete = (index: number) => {
    const newHighlights = localHighlights.filter((_, i) => i !== index);
    setLocalHighlights(newHighlights);
    onChange(newHighlights);
  };

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;

    if (!over || active.id === over.id) {
      return;
    }

    const oldIndex = parseInt(active.id.toString().replace('highlight-', ''));
    const newIndex = parseInt(over.id.toString().replace('highlight-', ''));

    const newHighlights = arrayMove(localHighlights, oldIndex, newIndex);
    setLocalHighlights(newHighlights);
    onChange(newHighlights);
  };

  // פילטר הדגשים ריקים לתצוגה
  const nonEmptyHighlights = localHighlights.filter(h => h.trim());

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
        <Typography variant="subtitle1">{label}</Typography>
        <Button
          size="small"
          startIcon={<AddIcon />}
          onClick={handleAdd}
          disabled={localHighlights.length >= maxItems}
        >
          הוסף הדגש
        </Button>
      </Box>

      {localHighlights.length === 0 ? (
        <Alert severity="info" sx={{ mb: 2 }}>
          אין הדגשים עדיין. לחץ על "הוסף הדגש" כדי להתחיל.
        </Alert>
      ) : (
        <>
          <DndContext
            sensors={sensors}
            collisionDetection={closestCenter}
            onDragEnd={handleDragEnd}
          >
            <SortableContext
              items={localHighlights.map((_, index) => `highlight-${index}`)}
              strategy={verticalListSortingStrategy}
            >
              {localHighlights.map((highlight, index) => (
                <HighlightItem
                  key={`highlight-${index}`}
                  highlight={highlight}
                  index={index}
                  onUpdate={handleUpdate}
                  onDelete={handleDelete}
                />
              ))}
            </SortableContext>
          </DndContext>

          {nonEmptyHighlights.length > 0 && (
            <Box sx={{ mt: 2, p: 2, backgroundColor: '#f5f5f5', borderRadius: 1 }}>
              <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 1 }}>
                תצוגה מקדימה:
              </Typography>
              <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                {nonEmptyHighlights.map((highlight, index) => (
                  <Chip
                    key={index}
                    label={highlight}
                    size="small"
                    color="primary"
                    variant="outlined"
                  />
                ))}
              </Box>
            </Box>
          )}

          {localHighlights.length >= maxItems && (
            <Alert severity="warning" sx={{ mt: 2 }}>
              הגעת למספר המקסימלי של הדגשים ({maxItems})
            </Alert>
          )}
        </>
      )}
    </Box>
  );
};

export default HighlightsManager; 