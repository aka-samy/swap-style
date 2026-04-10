import { Injectable, UnauthorizedException } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { PrismaService } from '../../common/prisma/prisma.service';
import { RegisterDto, UpdateFcmTokenDto } from './dto';

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService) {}

  async register(dto: RegisterDto) {
    const decodedToken = await this.verifyFirebaseToken(dto.firebaseIdToken);
    const email = decodedToken.email;
    if (!email) {
      throw new UnauthorizedException('Firebase account email is required');
    }

    const existingUser = await this.prisma.user.findUnique({
      where: { firebaseUid: decodedToken.uid },
    });
    if (existingUser) {
      await this.prisma.streak.upsert({
        where: { userId: existingUser.id },
        update: {},
        create: { userId: existingUser.id },
      });

      return {
        id: existingUser.id,
        name: existingUser.displayName,
        email: existingUser.email,
        emailVerified: existingUser.emailVerified,
        phoneVerified: existingUser.phoneVerified,
        createdAt: existingUser.createdAt,
      };
    }

    const existingEmailUser = await this.prisma.user.findUnique({
      where: { email },
    });
    if (existingEmailUser) {
      const relinkedUser = await this.prisma.user.update({
        where: { id: existingEmailUser.id },
        data: {
          firebaseUid: decodedToken.uid,
          emailVerified: decodedToken.email_verified ?? existingEmailUser.emailVerified,
          displayName: existingEmailUser.displayName || dto.name,
          latitude: dto.latitude,
          longitude: dto.longitude,
        },
      });

      await this.prisma.streak.upsert({
        where: { userId: relinkedUser.id },
        update: {},
        create: { userId: relinkedUser.id },
      });

      return {
        id: relinkedUser.id,
        name: relinkedUser.displayName,
        email: relinkedUser.email,
        emailVerified: relinkedUser.emailVerified,
        phoneVerified: relinkedUser.phoneVerified,
        createdAt: relinkedUser.createdAt,
      };
    }

    const user = await this.prisma.user.create({
      data: {
        email,
        displayName: dto.name,
        firebaseUid: decodedToken.uid,
        emailVerified: decodedToken.email_verified ?? false,
        latitude: dto.latitude,
        longitude: dto.longitude,
      },
    });

    // Ensure an initial streak exists for both new and recovered users.
    await this.prisma.streak.upsert({
      where: { userId: user.id },
      update: {},
      create: { userId: user.id },
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
