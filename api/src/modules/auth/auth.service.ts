import { Injectable, ConflictException, UnauthorizedException } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { PrismaService } from '../../common/prisma/prisma.service';
import { RegisterDto, UpdateFcmTokenDto } from './dto';

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService) {}

  async register(dto: RegisterDto) {
    const decodedToken = await this.verifyFirebaseToken(dto.firebaseIdToken);

    const existingUser = await this.prisma.user.findUnique({
      where: { firebaseUid: decodedToken.uid },
    });
    if (existingUser) {
      throw new ConflictException('User already registered');
    }

    const user = await this.prisma.user.create({
      data: {
        email: decodedToken.email!,
        displayName: dto.name,
        firebaseUid: decodedToken.uid,
        emailVerified: decodedToken.email_verified ?? false,
        latitude: dto.latitude,
        longitude: dto.longitude,
      },
    });

    // Create initial streak record
    await this.prisma.streak.create({
      data: { userId: user.id },
    });

    return {
      id: user.id,
      name: user.displayName,
      email: user.email,
      emailVerified: user.emailVerified,
      phoneVerified: user.phoneVerified,
      createdAt: user.createdAt,
    };
  }

  async updateFcmToken(userId: string, dto: UpdateFcmTokenDto) {
    await this.prisma.user.update({
      where: { id: userId },
      data: { fcmToken: dto.fcmToken },
    });
  }

  async getUserByFirebaseUid(uid: string) {
    return this.prisma.user.findUnique({
      where: { firebaseUid: uid },
    });
  }

  private async verifyFirebaseToken(idToken: string) {
    try {
      return await admin.auth().verifyIdToken(idToken);
    } catch {
      throw new UnauthorizedException('Invalid Firebase ID token');
    }
  }

  async verifyPhone(userId: string, firebaseIdToken: string) {
    // Firebase phone auth: user completes phone sign-in and provides the resulting token.
    // We verify the token and mark the user's phone as verified.
    const decoded = await this.verifyFirebaseToken(firebaseIdToken);
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        phoneVerified: true,
        phoneNumber: decoded.phone_number ?? null,
      },
    });
    return { phoneVerified: true };
  }
}
