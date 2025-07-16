import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { ExpenseService } from './expense.service';
import { ExpenseController } from './expense.controller';
import { Expense } from './expense.model';

@Module({
  imports: [SequelizeModule.forFeature([Expense])],
  controllers: [ExpenseController],
  providers: [ExpenseService],
  exports: [ExpenseService],
})
export class ExpenseModule {}