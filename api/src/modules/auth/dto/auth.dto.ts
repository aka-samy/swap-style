import { IsString, IsNumber, MinLength, MaxLength, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ description: 'Firebase ID token from client-side sign-in' })
  @IsString()
  @IsNotEmpty()
  firebaseIdToken: string;

  @ApiProperty({ description: 'Display name', minLength: 2, maxLength: 50 })
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  name: string;

  @ApiProperty({ description: 'User latitude' })
  @IsNumber()
  latitude: number;

  @ApiProperty({ description: 'User longitude' })
  @IsNumber()
  longitude: number;
}

export class VerifyPhoneDto {
  @ApiProperty({ description: 'Phone number in E.164 format', example: '+201234567890' })
  @IsString()
  @IsNotEmpty()
  phoneNumber: string;
}

export class VerifyPhoneConfirmDto {
  @ApiProperty({ description: '6-digit verification code' })
  @IsString()
  @MinLength(6)
  @MaxLength(6)
  verificationCode: string;
}

export class UpdateFcmTokenDto {
  @ApiProperty({ description: 'Firebase Cloud Messaging device token' })
  @IsString()
  @IsNotEmpty()
  fcmToken: string;
}
