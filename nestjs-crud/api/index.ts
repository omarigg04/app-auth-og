import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { VercelRequest, VercelResponse } from '@vercel/node';

let app: any;

async function createApp() {
  if (!app) {
    console.log('🚀 Creating NestJS app...');
    app = await NestFactory.create(AppModule, { 
      logger: ['error', 'warn'] 
    });
    await app.init();
    console.log('✅ NestJS app created');
  }
  return app;
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  console.log(`📥 ${req.method} ${req.url}`);
  
  // Set CORS headers FIRST
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept, Origin, X-Requested-With');
  res.setHeader('Access-Control-Max-Age', '86400');
  
  // Handle preflight OPTIONS requests
  if (req.method === 'OPTIONS') {
    console.log('🔧 Handling OPTIONS preflight');
    res.status(200).end();
    return;
  }

  try {
    const app = await createApp();
    console.log('🎯 Forwarding to NestJS...');
    
    // Get the Express instance
    const expressApp = app.getHttpAdapter().getInstance();
    
    // Forward the request to Express/NestJS
    expressApp(req, res);
    
  } catch (error) {
    console.error('💥 Error in handler:', error);
    res.status(500).json({ 
      error: 'Internal server error', 
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
}