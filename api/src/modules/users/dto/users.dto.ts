import { IsString, IsOptional, IsEnum, MaxLength } from 'class-validator';
import { ApiPropertyOptional, ApiProperty } from '@nestjs/swagger';
import { ItemCategory, ItemSize } from '@prisma/client';

export class UpdateProfileDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(100)
  displayName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  bio?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  profilePhotoUrl?: string;
}

export class CreateWishlistEntryDto {
  @ApiProperty({ enum: ItemCategory })
  @IsEnum(ItemCategory)
  category: ItemCategory;

  @ApiPropertyOptional({ enum: ItemSize })
  @IsOptional()
  @IsEnum(ItemSize)
  size?: ItemSize;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(100)
  brand?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(200)
  notes?: string;
}
