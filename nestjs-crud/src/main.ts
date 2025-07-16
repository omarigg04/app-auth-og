import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {


  const app = await NestFactory.create(AppModule);

  app.enableCors({
    origin: '*', // o restringido a IP de tu cel si prefieres
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  });

  await app.listen(process.env.PORT ?? 3000);

}
bootstrap();



