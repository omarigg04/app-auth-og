import { Table, Column, Model, DataType, PrimaryKey, AutoIncrement } from 'sequelize-typescript';

@Table({ tableName: 'auth_users', timestamps: true })
export class AuthUser extends Model<AuthUser> {
    @PrimaryKey
    @AutoIncrement
    @Column
    declare id: number;

    @Column({ type: DataType.STRING, unique: true, allowNull: false })
    declare email: string;

    @Column({ type: DataType.STRING, allowNull: false })
    declare password: string;

    @Column({ type: DataType.DATE, defaultValue: DataType.NOW })
    declare created_at: Date;

    @Column({ type: DataType.DATE, defaultValue: DataType.NOW })
    declare updated_at: Date;
}