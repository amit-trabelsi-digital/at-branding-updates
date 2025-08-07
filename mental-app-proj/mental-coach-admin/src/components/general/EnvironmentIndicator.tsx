import React from 'react';
import { Box, Typography, Tooltip, Fade } from '@mui/material';
import { appConfig } from '../../data/config';

const EnvironmentIndicator: React.FC = () => {
  const { environment } = appConfig;

  // לא מציגים את החיווי בסביבת פרודקשן
  if (environment === 'prod') {
    return null;
  }

  const indicatorData = {
    local: {
      label: 'L',
      title: 'סביבה מקומית (Local)',
      color: '#2196f3', // Blue
    },
    dev: {
      label: 'D',
      title: 'סביבת פיתוח (Dev)',
      color: '#ff9800', // Orange
    },
    prod: {
      label: 'P',
      title: 'סביבת פרודקשן (Prod)',
      color: '#f44336', // Red
    },
  };

  const currentIndicator = indicatorData[environment];

  return (
    <Tooltip
      title={currentIndicator.title}
      placement="left"
      TransitionComponent={Fade}
      arrow
    >
      <Box
        sx={{
          position: 'fixed',
          bottom: '10px',
          right: '10px',
          width: '24px',
          height: '24px',
          borderRadius: '50%',
          backgroundColor: currentIndicator.color,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          boxShadow: '0 2px 5px rgba(0,0,0,0.2)',
          cursor: 'pointer',
          zIndex: 1400, // מעל הכל
        }}
        onClick={() => alert(`מחובר לסביבת: ${currentIndicator.title}\nAPI URL: ${appConfig.apiBaseUrl}`)}
      >
        <Typography
          variant="caption"
          sx={{
            color: 'white',
            fontWeight: 'bold',
            fontSize: '12px',
          }}
        >
          {currentIndicator.label}
        </Typography>
      </Box>
    </Tooltip>
  );
};

export default EnvironmentIndicator; 