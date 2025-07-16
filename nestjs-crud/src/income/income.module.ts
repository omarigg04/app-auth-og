import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { IncomeService } from './income.service';
import { IncomeController } from './income.controller';
import { Income } from './income.model';

@Module({
  imports: [SequelizeModule.forFeature([Income])],
  controllers: [IncomeController],
  providers: [IncomeService],
  exports: [IncomeService],
})
export class IncomeModule {}