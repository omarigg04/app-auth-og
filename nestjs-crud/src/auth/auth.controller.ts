import { Controller, Post, Body, ValidationPipe, Get, HttpCode } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body(ValidationPipe) registerDto: RegisterDto) {
    console.log('POST /auth/register recibido:', registerDto.user_name);
    return this.authService.register(registerDto);
  }

  @Post('login')
  @HttpCode(200)
  async login(@Body(ValidationPipe) loginDto: LoginDto) {
    console.log('POST /auth/login recibido:', loginDto.user_name);
    return this.authService.login(loginDto);
  }

  @Get('test')
  async test() {
    return { message: 'Auth module working!', timestamp: new Date() };
  }
}