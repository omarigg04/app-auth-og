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
    const { email, password } = registerDto;

    // Verificar si el usuario ya existe
    const existingUser = await this.authUserModel.findOne({ where: { email } });
    if (existingUser) {
      throw new ConflictException('El email ya está registrado');
    }

    // Hash de la contraseña
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Crear usuario
    const user = await this.authUserModel.create({
      email,
      password: hashedPassword,
    } as any);

    // Generar JWT
    const payload = { email: user.email, sub: user.id };
    const access_token = this.jwtService.sign(payload);

    return {
      access_token,
      user: {
        id: user.id,
        email: user.email,
        created_at: user.created_at,
      },
    };
  }

  async login(loginDto: LoginDto): Promise<{ access_token: string; user: any }> {
    try {
      const { email, password } = loginDto;
      console.log('🔍 LOGIN - Email recibido:', email);
      console.log('🔍 LOGIN - Password length:', password.length);

      // Buscar usuario
      const user = await this.authUserModel.findOne({ where: { email } });
      console.log('🔍 LOGIN - Usuario encontrado:', user ? 'SÍ' : 'NO');
      
      if (!user) {
        console.log('❌ LOGIN - Usuario no encontrado para email:', email);
        throw new UnauthorizedException('Credenciales inválidas');
      }

      // Verificar contraseña
      console.log('🔍 LOGIN - Verificando contraseña...');
      const isPasswordValid = await bcrypt.compare(password, user.password);
      console.log('🔍 LOGIN - Password válido:', isPasswordValid ? 'SÍ' : 'NO');
      if (!isPasswordValid) {
        console.log('❌ LOGIN - Password inválido');
        throw new UnauthorizedException('Credenciales inválidas');
      }

      // Generar JWT
      console.log('🔍 LOGIN - Generando JWT...');
      const payload = { email: user.email, sub: user.id };
      const access_token = this.jwtService.sign(payload);
      console.log('✅ LOGIN - JWT generado exitosamente');

      return {
        access_token,
        user: {
          id: user.id,
          email: user.email,
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