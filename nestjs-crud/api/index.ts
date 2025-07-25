import { VercelRequest, VercelResponse } from '@vercel/node';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  // Set CORS headers first
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept, Origin, X-Requested-With');
  
  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    // Try to import and initialize NestJS only when needed
    const { NestFactory } = await import('@nestjs/core');
    const { AppModule } = await import('../src/app.module');
    
    const app = await NestFactory.create(AppModule, { 
      logger: false // Disable logging for serverless
    });
    
    await app.init();
    
    // Handle the request
    const expressApp = app.getHttpAdapter().getInstance();
    return new Promise((resolve) => {
      expressApp(req, res, () => {
        resolve(undefined);
      });
    });
    
  } catch (error) {
    console.error('Error:', error);
    
    // Fallback response
    res.status(200).json({
      message: 'API is running (fallback mode)',
      method: req.method,
      url: req.url,
      timestamp: new Date().toISOString(),
      error: error.message
    });
  }
}