import { Request, Response } from 'express';
import catchAsync from '../utils/catchAsync';
import fs from 'fs';
import path from 'path';

// קריאת הגרסה מ-version.json (ברירת מחדל) ו-package.json (גיבוי)
const versionFilePath = path.join(__dirname, '..', 'version.json');
const packageJsonPath = path.join(__dirname, '..', 'package.json');

let versionData;
try {
  versionData = JSON.parse(fs.readFileSync(versionFilePath, 'utf-8'));
} catch {
  try {
    // גיבוי למקרה שversion.json לא קיים
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
    versionData = {
      version: packageJson.version,
      name: packageJson.name,
      build: 'unknown',
      buildDate: new Date().toISOString()
    };
  } catch {
    // ברירת מחדל אם גם package.json לא נמצא
    versionData = {
      version: '1.1.0',
      name: 'mental-coach-api',
      build: 'production',
      buildDate: new Date().toISOString()
    };
  }
}

export const getApiStatus = catchAsync(async (req: Request, res: Response) => {
  const uptime = process.uptime();
  const memoryUsage = process.memoryUsage();
  
  res.status(200).json({
    status: 'success',
    data: {
      status: 'online',
      version: versionData.version,
      name: versionData.name,
      build: versionData.build,
      buildDate: versionData.buildDate,
      uptime: {
        seconds: uptime,
        formatted: formatUptime(uptime)
      },
      memory: {
        rss: formatBytes(memoryUsage.rss),
        heapUsed: formatBytes(memoryUsage.heapUsed),
        heapTotal: formatBytes(memoryUsage.heapTotal),
        external: formatBytes(memoryUsage.external)
      },
      environment: process.env.NODE_ENV || 'development',
      timestamp: new Date().toISOString()
    }
  });
});

export const getApiVersion = catchAsync(async (req: Request, res: Response) => {
  res.status(200).json({
    status: 'success',
    data: {
      version: versionData.version,
      name: versionData.name,
      build: versionData.build,
      buildDate: versionData.buildDate,
      description: versionData.description
    }
  });
});

// Helper functions
function formatUptime(seconds: number): string {
  const days = Math.floor(seconds / (3600 * 24));
  const hours = Math.floor((seconds % (3600 * 24)) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const remainingSeconds = Math.floor(seconds % 60);
  
  const parts = [];
  if (days > 0) parts.push(`${days} ימים`);
  if (hours > 0) parts.push(`${hours} שעות`);
  if (minutes > 0) parts.push(`${minutes} דקות`);
  if (remainingSeconds > 0) parts.push(`${remainingSeconds} שניות`);
  
  return parts.join(', ');
}

function formatBytes(bytes: number): string {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}