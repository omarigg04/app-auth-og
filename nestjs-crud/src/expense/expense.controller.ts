import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request } from '@nestjs/common';
import { ExpenseService } from './expense.service';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';
import { JwtAuthGuard } from '../auth/jwt.guard';

@Controller('expenses')
@UseGuards(JwtAuthGuard)
export class ExpenseController {
    constructor(private readonly expenseService: ExpenseService) {}

    @Post()
    create(@Body() createExpenseDto: CreateExpenseDto, @Request() req) {
        return this.expenseService.create(createExpenseDto, req.user.id);
    }

    @Get()
    findAll() {
        return this.expenseService.findAll();
    }

    @Get('my-expenses')
    findMyExpenses(@Request() req) {
        return this.expenseService.findAllByUser(req.user.id);
    }

    @Get('my-totals')
    getMyTotals(@Request() req) {
        return this.expenseService.getTotalExpensesByUser(req.user.id);
    }

    @Get(':id')
    findOne(@Param('id') id: string) {
        return this.expenseService.findOne(+id);
    }

    @Patch(':id')
    update(@Param('id') id: string, @Body() updateExpenseDto: UpdateExpenseDto, @Request() req) {
        return this.expenseService.update(+id, updateExpenseDto, req.user.id);
    }

    @Delete(':id')
    remove(@Param('id') id: string, @Request() req) {
        return this.expenseService.remove(+id, req.user.id);
    }
}