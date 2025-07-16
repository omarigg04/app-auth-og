import { Controller, Post, Body, ValidationPipe, Get } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body(ValidationPipe) registerDto: RegisterDto) {
    console.log('POST /auth/register recibido:', registerDto.email);
    return this.authService.register(registerDto);
  }

  @Post('login')
  async login(@Body(ValidationPipe) loginDto: LoginDto) {
    console.log('POST /auth/login recibido:', loginDto.email);
    return this.authService.login(loginDto);
  }

  @Get('test')
  async test() {
    return { message: 'Auth module working!', timestamp: new Date() };
  }
}