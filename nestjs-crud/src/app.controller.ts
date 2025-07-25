import { Controller, Get, Post, Body } from '@nestjs/common';

@Controller()
export class AppController {
  @Get()
  getHello(): string {
    return 'API funcionando';
  }

  @Get('health')
  healthCheck(): any {
    return { 
      status: 'OK', 
      message: 'API funcionando correctamente',
      timestamp: new Date().toISOString(),
      cors: 'enabled'
    };
  }

  @Post('test-cors')
  testCors(@Body() body: any): any {
    return { 
      message: 'CORS funcionando correctamente',
      receivedData: body,
      timestamp: new Date().toISOString()
    };
  }
}