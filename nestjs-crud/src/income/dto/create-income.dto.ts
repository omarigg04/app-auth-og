export class CreateIncomeDto {
    nombre_ingreso: string;
    monto: number;
    fuente_ingreso?: string;
    descripcion?: string;
    fecha_ingreso: Date;
}