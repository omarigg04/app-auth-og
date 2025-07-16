import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Expense } from './expense.model';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';

@Injectable()
export class ExpenseService {
    constructor(
        @InjectModel(Expense)
        private expenseModel: typeof Expense,
    ) {}

    async create(createExpenseDto: CreateExpenseDto, userId: number): Promise<Expense> {
        return this.expenseModel.create({
            ...createExpenseDto,
            user_id: userId,
        });
    }

    async findAll(): Promise<Expense[]> {
        return this.expenseModel.findAll({
            include: ['user'],
        });
    }

    async findAllByUser(userId: number): Promise<Expense[]> {
        return this.expenseModel.findAll({
            where: { user_id: userId },
            order: [['fecha_gasto', 'DESC']],
        });
    }

    async findOne(id: number): Promise<Expense> {
        return this.expenseModel.findByPk(id, {
            include: ['user'],
        });
    }

    async update(id: number, updateExpenseDto: UpdateExpenseDto, userId: number): Promise<[number, Expense[]]> {
        return this.expenseModel.update(updateExpenseDto, {
            where: { id, user_id: userId },
            returning: true,
        });
    }

    async remove(id: number, userId: number): Promise<number> {
        return this.expenseModel.destroy({
            where: { id, user_id: userId },
        });
    }

    async getTotalExpensesByUser(userId: number): Promise<{ total: number, credito: number, efectivo: number }> {
        const expenses = await this.findAllByUser(userId);
        
        const total = expenses.reduce((sum, expense) => sum + Number(expense.gasto), 0);
        const credito = expenses
            .filter(expense => expense.tipo_pago === 'credito')
            .reduce((sum, expense) => sum + Number(expense.gasto), 0);
        const efectivo = expenses
            .filter(expense => expense.tipo_pago === 'efectivo')
            .reduce((sum, expense) => sum + Number(expense.gasto), 0);

        return { total, credito, efectivo };
    }
}