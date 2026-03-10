import { IsOptional, IsString } from 'class-validator';
import { ApiPropertyOptional, ApiProperty } from '@nestjs/swagger';

export class GetBadgesQueryDto {
  @ApiPropertyOptional({ description: 'Filter by badge slug' })
  @IsOptional()
  @IsString()
  slug?: string;
}

// ─── Response shapes ────────────────────────────────────

export class StreakResponseDto {
  @ApiProperty() currentStreak: number;
  @ApiProperty() longestStreak: number;
  @ApiProperty() lastActivityAt: Date;
}

export class BadgeResponseDto {
  @ApiProperty() id: string;
  @ApiProperty() slug: string;
  @ApiProperty() name: string;
  @ApiProperty() description: string;
  @ApiProperty() iconUrl: string;
  @ApiProperty() awardedAt: Date;
}

export class GamificationStatsDto {
  @ApiProperty({ type: StreakResponseDto }) streak: StreakResponseDto | null;
  @ApiProperty({ type: [BadgeResponseDto] }) badges: BadgeResponseDto[];
}
