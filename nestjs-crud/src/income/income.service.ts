import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Income } from './income.model';
import { CreateIncomeDto } from './dto/create-income.dto';
import { UpdateIncomeDto } from './dto/update-income.dto';

@Injectable()
export class IncomeService {
    constructor(
        @InjectModel(Income)
        private incomeModel: typeof Income,
    ) {}

    async create(createIncomeDto: CreateIncomeDto, userId: number): Promise<Income> {
        return this.incomeModel.create({
            ...createIncomeDto,
            user_id: userId,
        } as any);
    }

    async findAll(): Promise<Income[]> {
        return this.incomeModel.findAll({
            include: ['user'],
        });
    }

    async findAllByUser(userId: number): Promise<Income[]> {
        return this.incomeModel.findAll({
            where: { user_id: userId },
            order: [['fecha_ingreso', 'DESC']],
        });
    }

    async findOne(id: number): Promise<Income | null> {
        return this.incomeModel.findByPk(id, {
            include: ['user'],
        });
    }

    async update(id: number, updateIncomeDto: UpdateIncomeDto, userId: number): Promise<[number, Income[]]> {
        return this.incomeModel.update(updateIncomeDto, {
            where: { id, user_id: userId },
            returning: true,
        });
    }

    async remove(id: number, userId: number): Promise<number> {
        return this.incomeModel.destroy({
            where: { id, user_id: userId },
        });
    }

    async getTotalIncomesByUser(userId: number): Promise<{ total: number, por_fuente: { [key: string]: number } }> {
        const incomes = await this.findAllByUser(userId);
        
        const total = incomes.reduce((sum, income) => sum + Number(income.monto), 0);
        
        const por_fuente = incomes.reduce((acc, income) => {
            const fuente = income.fuente_ingreso || 'Sin especificar';
            acc[fuente] = (acc[fuente] || 0) + Number(income.monto);
            return acc;
        }, {} as { [key: string]: number });

        return { total, por_fuente };
    }

    async getIncomesByDateRange(userId: number, startDate: Date, endDate: Date): Promise<Income[]> {
        return this.incomeModel.findAll({
            where: {
                user_id: userId,
                fecha_ingreso: {
                    [require('sequelize').Op.between]: [startDate, endDate],
                },
            },
            order: [['fecha_ingreso', 'DESC']],
        });
    }
}