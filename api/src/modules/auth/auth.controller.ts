import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto, UpdateFcmTokenDto } from './dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Register a new user' })
  @ApiResponse({ status: 201, description: 'User registered successfully' })
  @ApiResponse({ status: 409, description: 'User already exists' })
  async register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('fcm-token')
  @UseGuards(FirebaseAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Update FCM device token' })
  async updateFcmToken(@Req() req: any, @Body() dto: UpdateFcmTokenDto) {
    const user = await this.authService.getUserByFirebaseUid(req.user.uid);
    if (user) {
      await this.authService.updateFcmToken(user.id, dto);
    }
  }

  @Post('verify-phone')
  @UseGuards(FirebaseAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Verify phone number via Firebase phone auth token' })
  async verifyPhone(
    @Req() req: any,
    @Body() body: { firebaseIdToken: string },
  ) {
    const user = await this.authService.getUserByFirebaseUid(req.user.uid);
    return this.authService.verifyPhone(user!.id, body.firebaseIdToken);
  }
}
