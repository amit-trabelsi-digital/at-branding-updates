import { appConfig } from '../data/config';
import { fireAuth } from '../utils/firebase';

/**
 * פונקציית fetch שעוטפת את ה-API של האפליקציה,
 * מוסיפה את טוקן האימות של Firebase לכל בקשה,
 * ומחזירה את התגובה הגולמית (Response object).
 */
export const appFetch = async (url: string, options: RequestInit = {}): Promise<Response> => {
  const token = (await fireAuth.currentUser?.getIdToken()) || '';
  const fullUrl = url.startsWith('http') ? url : `${appConfig.apiBaseUrl}${url}`;

  const defaultOptions: RequestInit = {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
      ...options.headers,
    },
  };

  return fetch(fullUrl, defaultOptions);
};
