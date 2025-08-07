import express from 'express';
import * as infoController from '../controllers/info-controller';

const router = express.Router();

// Endpoint to get API info and status
router.get('/status', infoController.getApiStatus);
router.get('/version', infoController.getApiVersion);

export default router;