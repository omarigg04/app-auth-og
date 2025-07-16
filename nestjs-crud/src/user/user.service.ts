import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { User } from './user.model';
import { CreateUserDto } from './dto/create-user.dto';
// import { CreationAttributes } from 'sequelize-typescript';

@Injectable()
export class UserService {
  constructor(
    @InjectModel(User)
    private userModel: typeof User,
  ) { }

  async create(data: CreateUserDto): Promise<User> {
    console.log('UserService.create llamado con:', data); // <-- LOG
    return this.userModel.create(data as any);
  }

  async findAll(): Promise<User[]> {
    return this.userModel.findAll();
  }

  async findById(id: string): Promise<User | null> {
    return this.userModel.findByPk(id);
  }
  
  async findByName(nombre: string): Promise<User | null> {
    return this.userModel.findOne({ where: { nombre } });
  }

  async updateElement(id: string, data: Partial<CreateUserDto>): Promise<User> {
    const user = await this.findById(id);
    if (!user) {
      throw new NotFoundException(`Usuario con ID ${id} no encontrado`);
    }
    return user.update(data);
  }

  async deleteElement(id: string): Promise<boolean> {
    const user = await this.findById(id);
    if (!user) {
      throw new NotFoundException(`Usuario con ID ${id} no encontrado`);
    }
    await user.destroy();
    return true;
  }
}