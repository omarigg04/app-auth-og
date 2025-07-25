import { Module, MiddlewareConsumer, NestModule } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { User } from './user/user.model';
import { AuthUser } from './auth/auth-user.model';
import { Expense } from './expense/expense.model';
import { Income } from './income/income.model';
import { ConfigModule } from '@nestjs/config';
import { UserModule } from './user/user.module';
import { AuthModule } from './auth/auth.module';
import { ExpenseModule } from './expense/expense.module';
import { IncomeModule } from './income/income.module';
import { TestModule } from './test/test.module';
import { CorsMiddleware } from './cors.middleware'; 

@Module({
  imports: [
    ConfigModule.forRoot({ 
      isGlobal: true,
      // Solo carga archivos .env en desarrollo o si no está en Vercel
      envFilePath: ['.env.local', '.env.aws'],
    }),
    SequelizeModule.forRoot({
      dialect: 'mysql',
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT),
      username: process.env.DB_USER,
      password: process.env.DB_PASS,
      database: process.env.DB_NAME,
      models: [User, AuthUser, Expense, Income],
      autoLoadModels: true,
      synchronize: true, // ponlo en true solo si quieres que cree la tabla automáticamente
    }),
    SequelizeModule.forFeature([User]),
    UserModule,
    AuthModule,
    ExpenseModule,
    IncomeModule,
    TestModule,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(CorsMiddleware)
      .forRoutes('*');
  }
}