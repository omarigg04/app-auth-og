import { IsNotEmpty, MinLength } from 'class-validator';

export class LoginDto {
  @IsNotEmpty()
  user_name: string;

  @IsNotEmpty()
  @MinLength(6)
  password: string;
}