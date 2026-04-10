import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import * as admin from 'firebase-admin';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(private readonly prisma: PrismaService) {}

  private async resolveDbUser(decodedToken: admin.auth.DecodedIdToken) {
    const existingByUid = await this.prisma.user.findUnique({
      where: { firebaseUid: decodedToken.uid },
    });
    if (existingByUid) return existingByUid;

    const email = decodedToken.email;
    if (!email) {
      throw new UnauthorizedException(
        'Account email is missing. Please sign in again with an email provider.',
      );
    }

    const existingByEmail = await this.prisma.user.findUnique({
      where: { email },
    });

    const displayNameFromToken =
      decodedToken.name || email.split('@')[0] || 'SwapStyle User';

    const user = existingByEmail
      ? await this.prisma.user.update({
          where: { id: existingByEmail.id },
          data: {
            firebaseUid: decodedToken.uid,
            emailVerified:
              decodedToken.email_verified ?? existingByEmail.emailVerified,
            displayName: existingByEmail.displayName || displayNameFromToken,
          },
        })
      : await this.prisma.user.create({
          data: {
            email,
            displayName: displayNameFromToken,
            firebaseUid: decodedToken.uid,
            emailVerified: decodedToken.email_verified ?? false,
          },
        });

    await this.prisma.streak.upsert({
      where: { userId: user.id },
      update: {},
      create: { userId: user.id },
    });

    return user;
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers.authorization;

    if (!authHeader?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing or invalid authorization header');
    }

    const token = authHeader.split('Bearer ')[1];

    try {
      const decodedToken = await admin.auth().verifyIdToken(token);

      // Resolve account for legacy users by Firebase UID or email.
      const dbUser = await this.resolveDbUser(decodedToken);

      const dbUserAny = dbUser as any;
      if (
        dbUserAny.suspendedUntil &&
        new Date(dbUserAny.suspendedUntil).getTime() > Date.now()
      ) {
        throw new UnauthorizedException('Account is temporarily suspended');
      }

      request.user = {
        uid: decodedToken.uid,
        userId: dbUser.id,
        email: decodedToken.email,
        emailVerified: decodedToken.email_verified,
        role: dbUserAny.role ?? 'USER',
      };
      return true;
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new UnauthorizedException('Invalid or expired token');
    }
  }
}
