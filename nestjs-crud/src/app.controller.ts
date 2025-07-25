import { Controller, Get, Post, Body } from '@nestjs/common';

@Controller()
export class AppController {
  @Get()
  getHello(): any {
    return {
      message: 'API funcionando',
      timestamp: new Date().toISOString(),
      cors: 'enabled'
    };
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

  @Get('test/cors')
  testCorsGet(): any {
    return {
      message: 'GET CORS está funcionando correctamente!',
      timestamp: new Date().toISOString(),
      status: 'success'
    };
  }

  @Post('test/cors')
  testCorsPost(@Body() body: any): any {
    return { 
      message: 'POST CORS está funcionando correctamente!',
      receivedData: body,
      timestamp: new Date().toISOString(),
      status: 'success'
    };
  }
}