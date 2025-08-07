import { Request, Response, NextFunction } from "express";
import crypto from "crypto";
import AppError from "../utils/appError";

// Store API keys in environment variables or database
// For production, these should be stored securely (e.g., in database with hashed values)
const API_KEYS = process.env.EXTERNAL_API_KEYS ? 
  process.env.EXTERNAL_API_KEYS.split(',') : 
  ['test-key-development-only']; // Default for development

interface ExternalApiRequest extends Request {
  apiClient?: {
    key: string;
    clientId?: string;
    permissions?: string[];
  };
}

/**
 * Middleware to authenticate external API requests
 * Supports both header and query parameter authentication
 */
export const authenticateExternalApi = async (
  req: ExternalApiRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Check for API key in headers or query params
    const apiKey = req.headers['x-api-key'] as string || 
                   req.query.api_key as string;

    if (!apiKey) {
      return next(new AppError('API key is required', 401));
    }

    // Validate API key format (should be at least 32 characters for production)
    // Allow test keys in development mode
    const isDevelopmentTestKey = process.env.NODE_ENV === 'development' && 
                                  apiKey === 'test-key-development-only';
    
    if (!isDevelopmentTestKey && apiKey.length < 32) {
      return next(new AppError('Invalid API key format', 401));
    }

    // Check if API key exists in allowed keys
    const isValidKey = API_KEYS.includes(apiKey);
    
    if (!isValidKey) {
      // Log failed attempt for security monitoring
      console.warn(`Failed API authentication attempt with key: ${apiKey.substring(0, 8)}...`);
      return next(new AppError('Invalid API key', 401));
    }

    // Store API client info in request for logging/rate limiting
    req.apiClient = {
      key: apiKey.substring(0, 8) + '...', // Store partial key for logging
      clientId: req.headers['x-client-id'] as string,
      permissions: ['create:users'] // Can be extended based on key
    };

    // Log successful authentication
    console.log(`External API authenticated: Client ${req.apiClient.clientId || 'Unknown'}`);

    next();
  } catch (error) {
    console.error('External API authentication error:', error);
    return next(new AppError('Authentication failed', 500));
  }
};

/**
 * Rate limiting middleware for external API
 * Prevents abuse by limiting requests per API key
 */
const rateLimitStore = new Map<string, { count: number; resetTime: number }>();

export const rateLimitExternalApi = (
  maxRequests: number = 100,
  windowMs: number = 60000 // 1 minute
) => {
  return (req: ExternalApiRequest, res: Response, next: NextFunction) => {
    const apiKey = req.headers['x-api-key'] as string || req.query.api_key as string;
    
    if (!apiKey) {
      return next();
    }

    const now = Date.now();
    const keyData = rateLimitStore.get(apiKey) || { count: 0, resetTime: now + windowMs };

    // Reset if window has passed
    if (now > keyData.resetTime) {
      keyData.count = 0;
      keyData.resetTime = now + windowMs;
    }

    keyData.count++;
    rateLimitStore.set(apiKey, keyData);

    // Check if limit exceeded
    if (keyData.count > maxRequests) {
      res.setHeader('X-RateLimit-Limit', maxRequests.toString());
      res.setHeader('X-RateLimit-Remaining', '0');
      res.setHeader('X-RateLimit-Reset', new Date(keyData.resetTime).toISOString());
      
      return next(new AppError('Rate limit exceeded', 429));
    }

    // Set rate limit headers
    res.setHeader('X-RateLimit-Limit', maxRequests.toString());
    res.setHeader('X-RateLimit-Remaining', (maxRequests - keyData.count).toString());
    res.setHeader('X-RateLimit-Reset', new Date(keyData.resetTime).toISOString());

    next();
  };
};

/**
 * Generate a new API key for external services
 * This should be called by admin only
 */
export const generateApiKey = (clientId: string): string => {
  const timestamp = Date.now().toString();
  const random = crypto.randomBytes(16).toString('hex');
  const hash = crypto.createHash('sha256')
    .update(`${clientId}-${timestamp}-${random}`)
    .digest('hex');
  
  return `mc_${hash}`; // Prefix with 'mc_' for Mental Coach
};