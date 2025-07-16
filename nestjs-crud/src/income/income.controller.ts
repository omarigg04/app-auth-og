import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request, Query } from '@nestjs/common';
import { IncomeService } from './income.service';
import { CreateIncomeDto } from './dto/create-income.dto';
import { UpdateIncomeDto } from './dto/update-income.dto';
import { JwtAuthGuard } from '../auth/jwt.guard';

@Controller('incomes')
@UseGuards(JwtAuthGuard)
export class IncomeController {
    constructor(private readonly incomeService: IncomeService) {}

    @Post()
    create(@Body() createIncomeDto: CreateIncomeDto, @Request() req) {
        return this.incomeService.create(createIncomeDto, req.user.id);
    }

    @Get()
    findAll() {
        return this.incomeService.findAll();
    }

    @Get('my-incomes')
    findMyIncomes(@Request() req) {
        return this.incomeService.findAllByUser(req.user.id);
    }

    @Get('my-totals')
    getMyTotals(@Request() req) {
        return this.incomeService.getTotalIncomesByUser(req.user.id);
    }

    @Get('by-date-range')
    getIncomesByDateRange(
        @Request() req,
        @Query('startDate') startDate: string,
        @Query('endDate') endDate: string,
    ) {
        return this.incomeService.getIncomesByDateRange(
            req.user.id,
            new Date(startDate),
            new Date(endDate),
        );
    }

    @Get(':id')
    findOne(@Param('id') id: string) {
        return this.incomeService.findOne(+id);
    }

    @Patch(':id')
    update(@Param('id') id: string, @Body() updateIncomeDto: UpdateIncomeDto, @Request() req) {
        return this.incomeService.update(+id, updateIncomeDto, req.user.id);
    }

    @Delete(':id')
    remove(@Param('id') id: string, @Request() req) {
        return this.incomeService.remove(+id, req.user.id);
    }
}