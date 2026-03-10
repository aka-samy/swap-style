import {
  IsString,
  IsNotEmpty,
  MaxLength,
  IsOptional,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ReportUserDto {
  @ApiProperty({ description: 'UUID of the user being reported' })
  @IsString()
  @IsNotEmpty()
  targetUserId: string;

  @ApiProperty({ description: 'Short reason for the report', maxLength: 120 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  reason: string;

  @ApiPropertyOptional({ description: 'Optional detailed description', maxLength: 1000 })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  details?: string;
}

export class ReportItemDto {
  @ApiProperty({ description: 'UUID of the item being reported' })
  @IsString()
  @IsNotEmpty()
  targetItemId: string;

  @ApiProperty({ maxLength: 120 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  reason: string;

  @ApiPropertyOptional({ maxLength: 1000 })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  details?: string;
}
