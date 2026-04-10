import { IsString, IsEnum, IsOptional, IsNumber, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { ItemCategory, ItemSize } from '@prisma/client';

export class FeedQueryDto {
  @ApiPropertyOptional({ default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(50)
  limit?: number = 20;

  @ApiProperty({ description: 'User latitude' })
  @Type(() => Number)
  @IsNumber()
  latitude: number;

  @ApiProperty({ description: 'User longitude' })
  @Type(() => Number)
  @IsNumber()
  longitude: number;

  @ApiPropertyOptional({ default: 50, description: 'Search radius in km' })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  radiusKm?: number = 50;

  @ApiPropertyOptional({ description: 'Filter by size' })
  @IsOptional()
  @IsEnum(ItemSize)
  size?: ItemSize;

  @ApiPropertyOptional({ description: 'Filter by category' })
  @IsOptional()
  @IsEnum(ItemCategory)
  category?: ItemCategory;

  @ApiPropertyOptional({ description: 'Filter by EU shoe size', example: 42 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(30)
  @Max(55)
  shoeSizeEu?: number;
}

export class SwipeDto {
  @ApiProperty({ description: 'Item ID being swiped on' })
  @IsString()
  itemId: string;

  @ApiProperty({ enum: ['like', 'pass'] })
  @IsEnum(['like', 'pass'] as any)
  @IsString()
  action: 'like' | 'pass';
}
