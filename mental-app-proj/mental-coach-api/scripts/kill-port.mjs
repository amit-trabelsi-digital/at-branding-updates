#!/usr/bin/env node

import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

const port = process.argv[2] || 3000;

async function killPort(port) {
  try {
    console.log(`🔍 מחפש תהליכים על פורט ${port}...`);
    
    // מציאת התהליך שרץ על הפורט
    const { stdout } = await execAsync(`lsof -ti:${port}`);
    
    if (stdout) {
      const pids = stdout.trim().split('\n');
      console.log(`🎯 נמצאו תהליכים: ${pids.join(', ')}`);
      
      // הריגת התהליכים
      for (const pid of pids) {
        try {
          await execAsync(`kill -9 ${pid}`);
          console.log(`✅ תהליך ${pid} נהרג בהצלחה`);
        } catch (error) {
          console.error(`❌ שגיאה בהריגת תהליך ${pid}:`, error.message);
        }
      }
      
      console.log(`🎉 פורט ${port} פנוי כעת!`);
    } else {
      console.log(`✨ פורט ${port} כבר פנוי`);
    }
  } catch (error) {
    if (error.code === 1) {
      console.log(`✨ פורט ${port} כבר פנוי`);
    } else {
      console.error('❌ שגיאה:', error.message);
    }
  }
}

// הרצת הפונקציה
killPort(port); 