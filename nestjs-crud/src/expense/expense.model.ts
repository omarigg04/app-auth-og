import { Table, Column, Model, DataType, PrimaryKey, AutoIncrement, BelongsTo, ForeignKey } from 'sequelize-typescript';
import { AuthUser } from '../auth/auth-user.model';

@Table({ 
    tableName: 'expenses', 
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
})
export class Expense extends Model<Expense> {
    @PrimaryKey
    @AutoIncrement
    @Column
    declare id: number;

    @ForeignKey(() => AuthUser)
    @Column({ type: DataType.INTEGER, allowNull: false })
    declare user_id: number;

    @Column({ type: DataType.STRING, allowNull: false })
    declare nombre_gasto: string;

    @Column({ type: DataType.DECIMAL(10, 2), allowNull: false })
    declare gasto: number;

    @Column({ type: DataType.ENUM('credito', 'efectivo'), allowNull: false })
    declare tipo_pago: 'credito' | 'efectivo';

    @Column({ type: DataType.TEXT })
    declare descripcion: string;

    @Column({ type: DataType.DATE, allowNull: false })
    declare fecha_gasto: Date;

    @Column({ type: DataType.DATE, defaultValue: DataType.NOW })
    declare created_at: Date;

    @Column({ type: DataType.DATE, defaultValue: DataType.NOW })
    declare updated_at: Date;

    @BelongsTo(() => AuthUser)
    declare user: AuthUser;
}