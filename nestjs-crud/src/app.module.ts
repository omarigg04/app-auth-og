import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { User } from './user/user.model';
import { AuthUser } from './auth/auth-user.model';
import { ConfigModule } from '@nestjs/config';
import { UserModule } from './user/user.module';
import { AuthModule } from './auth/auth.module'; 

@Module({
  imports: [
    ConfigModule.forRoot({ 
      isGlobal: true,
      // Solo carga archivos .env en desarrollo o si no está en Vercel
      envFilePath: process.env.NODE_ENV !== 'production' ? '.env.localwsl' : undefined, // ✅
      // Las variables de process.env tendrán prioridad sobre las de los archivos
      ignoreEnvFile: process.env.NODE_ENV === 'production',
    }),
    SequelizeModule.forRoot({
      dialect: 'mysql',
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT),
      username: process.env.DB_USER,
      password: process.env.DB_PASS,
      database: process.env.DB_NAME,
      models: [User, AuthUser],
      autoLoadModels: true,
      synchronize: true, // ponlo en true solo si quieres que cree la tabla automáticamente
    }),
    SequelizeModule.forFeature([User]),
    UserModule,
    AuthModule,
  ],
})
export class AppModule { }