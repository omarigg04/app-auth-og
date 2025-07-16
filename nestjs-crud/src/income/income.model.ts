import { Table, Column, Model, DataType, PrimaryKey, AutoIncrement, BelongsTo, ForeignKey } from 'sequelize-typescript';
import { AuthUser } from '../auth/auth-user.model';

@Table({ tableName: 'incomes', timestamps: true })
export class Income extends Model<Income> {
    @PrimaryKey
    @AutoIncrement
    @Column
    declare id: number;

    @ForeignKey(() => AuthUser)
    @Column({ type: DataType.INTEGER, allowNull: false })
    declare user_id: number;

    @Column({ type: DataType.STRING, allowNull: false })
    declare nombre_ingreso: string;

    @Column({ type: DataType.DECIMAL(10, 2), allowNull: false })
    declare monto: number;

    @Column({ type: DataType.STRING(100) })
    declare fuente_ingreso: string;

    @Column({ type: DataType.TEXT })
    declare descripcion: string;

    @Column({ type: DataType.DATE, allowNull: false })
    declare fecha_ingreso: Date;

    @Column({ type: DataType.DATE, defaultValue: DataType.NOW })
    declare created_at: Date;

    @Column({ type: DataType.DATE, defaultValue: DataType.NOW })
    declare updated_at: Date;

    @BelongsTo(() => AuthUser)
    declare user: AuthUser;
}