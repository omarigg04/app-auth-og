import { Put, Delete, Post, Get, Body, Controller, Param, NotFoundException } from '@nestjs/common';
import { UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';

@Controller('usuarios')
export class UserController {
  constructor(private readonly userService: UserService) { }

  // Crea un nuevo usuario
  // POST /users
  // Nota: Asegúrate de que el DTO esté correctamente definido
  // y que los datos enviados en el cuerpo de la solicitud coincidan con las propiedades del DTO.
  // Ejemplo: POST /users con el cuerpo { "user": "usuario1", "nombre": "Nombre1", "edad": 25 }
  @Post()
  async create(@Body() body: CreateUserDto) {
    console.log('POST /users recibido:', body); // <-- LOG
    return this.userService.create(body);
  }

  // Obtiene todos los usuarios
  // GET /users/all 
  // Nota: Puedes usar findAll de Sequelize para obtener todos los registros
  // Ejemplo: GET /users/all
  // Si estás usando Sequelize, puedes usar findAll
  // o findAndCountAll si necesitas contar los registros.
  @Get('all')
  async findAll() {
    console.log('GET /users recibido'); // <-- LOG
    return this.userService.findAll();
  }

  // Obtiene un usuario por ID
  // GET /users/:id
  // Nota: Asegúrate de que el ID sea un número o una cadena que pueda ser convertida a un número
  // Si estás usando Sequelize, puedes usar findByPk
  // o findOne con un filtro adecuado.
  // Ejemplo: GET /users/1
  @Get(':id')
  async findOne(@Param('id') id: string) {
    console.log(`GET /users/${id} recibido`); // <-- LOG
    return this.userService.findById(id);
  }

  // Obtiene un usuario por nombre
  // GET /users/by-name/:nombre
  // Nota: Asegúrate de que el nombre sea una cadena válida
  // Si estás usando Sequelize, puedes usar findOne con un filtro adecuado.
  @Get('by-name/:nombre')
  async findByName(@Param('nombre') nombre: string) {
    console.log(`GET /users/by-name/${nombre} recibido`); // <-- LOG
    return this.userService.findByName(nombre);
  }

  //Edita un usuario por ID
  // PUT /users/:id
  // en el body debes enviar los datos que quieres actualizar
  // Ejemplo: PUT /users/1 con el cuerpo { "user": "nuevoUsuario", "nombre": "NuevoNombre", "edad": 30 }
  // Nota: Asegúrate de que el ID sea un número o una cadena que
  @Put(':id')
  async update(@Param('id') id: string, @Body() body: Partial<CreateUserDto>) {
    console.log(`PUT /users/${id} recibido con datos:`, body);
    return this.userService.updateElement(id, body);
  }

  // Elimina un usuario por ID
  // DELETE /users/:id
  // Nota: Asegúrate de que el ID sea un número o una cadena que
  // pueda ser convertida a un número
  @Delete (':id')
  async delete(@Param('id') id: string) {
    console.log(`DELETE /users/${id} recibido`); // <-- LOG
    const deleted = await this.userService.deleteElement(id);
    if (!deleted) {
      throw new NotFoundException(`Usuario con ID ${id} no encontrado`);
    }
    return { message: `Usuario con ID ${id} eliminado` };
  }

}