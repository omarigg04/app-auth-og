export class CreateExpenseDto {
    nombre_gasto: string;
    gasto: number;
    tipo_pago: 'credito' | 'efectivo';
    descripcion?: string;
    fecha_gasto: Date;
}