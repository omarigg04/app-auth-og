import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectModel } from '@nestjs/sequelize';
import * as bcrypt from 'bcrypt';
import { AuthUser } from './auth-user.model';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectModel(AuthUser)
    private authUserModel: typeof AuthUser,
    private jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto): Promise<{ access_token: string; user: any }> {
    const { email, user_name, password } = registerDto;

    // Verificar si el email ya existe
    const existingUserByEmail = await this.authUserModel.findOne({ where: { email } });
    if (existingUserByEmail) {
      throw new ConflictException('El email ya está registrado');
    }

    // Verificar si el username ya existe
    const existingUserByUsername = await this.authUserModel.findOne({ where: { user_name } });
    if (existingUserByUsername) {
      throw new ConflictException('El nombre de usuario ya está registrado');
    }

    // Hash de la contraseña
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Crear usuario
    const user = await this.authUserModel.create({
      email,
      user_name,
      password: hashedPassword,
    } as any);

    // Generar JWT
    const payload = { user_name: user.user_name, sub: user.id };
    const access_token = this.jwtService.sign(payload);

    return {
      access_token,
      user: {
        id: user.id,
        email: user.email,
        user_name: user.user_name,
        created_at: user.created_at,
      },
    };
  }

  async login(loginDto: LoginDto): Promise<{ access_token: string; user: any }> {
    try {
      const { user_name, password } = loginDto;
      console.log('🔍 LOGIN - Username recibido:', user_name);
      console.log('🔍 LOGIN - Password length:', password.length);

      // Buscar usuario
      const user = await this.authUserModel.findOne({ where: { user_name } });
      console.log('🔍 LOGIN - Usuario encontrado:', user ? 'SÍ' : 'NO');
      
      if (!user) {
        console.log('❌ LOGIN - Usuario no encontrado para username:', user_name);
        throw new UnauthorizedException('Credenciales inválidas');
      }

      // Verificar contraseña
      console.log('🔍 LOGIN - Verificando contraseña...');
      console.log('🔍 LOGIN - Password del usuario desde BD:', user.password ? 'EXISTE' : 'NULL/UNDEFINED');
      console.log('🔍 LOGIN - Password length desde BD:', user.password?.length || 'N/A');
      const isPasswordValid = await bcrypt.compare(password, user.password);
      console.log('🔍 LOGIN - Password válido:', isPasswordValid ? 'SÍ' : 'NO');
      if (!isPasswordValid) {
        console.log('❌ LOGIN - Password inválido');
        throw new UnauthorizedException('Credenciales inválidas');
      }

      // Generar JWT
      console.log('🔍 LOGIN - Generando JWT...');
      const payload = { user_name: user.user_name, sub: user.id };
      const access_token = this.jwtService.sign(payload);
      console.log('✅ LOGIN - JWT generado exitosamente');

      return {
        access_token,
        user: {
          id: user.id,
          email: user.email,
          user_name: user.user_name,
          created_at: user.created_at,
        },
      };
    } catch (error) {
      console.error('💥 LOGIN ERROR:', error);
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new Error('Error interno en el login: ' + error.message);
    }
  }

  async validateUser(userId: number): Promise<any> {
    const user = await this.authUserModel.findByPk(userId);
    if (user) {
      const { password, ...result } = user.toJSON();
      return result;
    }
    return null;
  }
}