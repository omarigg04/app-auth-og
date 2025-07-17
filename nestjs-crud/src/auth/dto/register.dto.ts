import { IsEmail, IsNotEmpty, MinLength, IsAlphanumeric } from 'class-validator';

export class RegisterDto {
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsNotEmpty()
  @IsAlphanumeric()
  @MinLength(3)
  user_name: string;

  @IsNotEmpty()
  @MinLength(6)
  password: string;
}