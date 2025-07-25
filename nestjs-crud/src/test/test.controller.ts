import { Controller, Get, Post, Body } from '@nestjs/common';

@Controller('test')
export class TestController {
  @Get('cors')
  testCors(): any {
    return {
      message: 'CORS está funcionando correctamente!',
      timestamp: new Date().toISOString(),
      status: 'success'
    };
  }

  @Post('cors')
  testCorsPost(@Body() body: any): any {
    return {
      message: 'POST CORS está funcionando correctamente!',
      receivedData: body,
      timestamp: new Date().toISOString(),
      status: 'success'
    };
  }
}