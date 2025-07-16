import { Table, Column, Model, DataType, PrimaryKey, AutoIncrement } from 'sequelize-typescript';

@Table({ tableName: 'usuarios', timestamps: false })
export class User extends Model<User> {
    @PrimaryKey
    @AutoIncrement
    @Column
    declare id: number;

    @Column({ type: DataType.STRING })
    user: string;

    @Column({ type: DataType.STRING })
    nombre: string;

    @Column({ type: DataType.INTEGER })
    edad: number;
}