import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {


  const app = await NestFactory.create(AppModule);

  // CORS está manejado por el middleware personalizado

  await app.listen(process.env.PORT ?? 3000);

}
bootstrap();



