import {
  IsString,
  IsEnum,
  IsOptional,
  IsNumber,
  MinLength,
  MaxLength,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { ItemCategory, ItemSize, ItemCondition } from '@prisma/client';

export class CreateItemDto {
  @ApiProperty({ enum: ItemCategory })
  @IsEnum(ItemCategory)
  category: ItemCategory;

  @ApiProperty({ minLength: 1, maxLength: 100 })
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  brand: string;

  @ApiProperty({ enum: ItemSize })
  @IsEnum(ItemSize)
  size: ItemSize;

  @ApiProperty({ enum: ItemCondition })
  @IsEnum(ItemCondition)
  condition: ItemCondition;

  @ApiPropertyOptional({ maxLength: 500 })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string;

  @ApiProperty()
  @IsNumber()
  latitude: number;

  @ApiProperty()
  @IsNumber()
  longitude: number;
}

export class UpdateItemDto extends PartialType(CreateItemDto) {}

export class PaginationQueryDto {
  @ApiPropertyOptional({ default: 1 })
  @IsOptional()
  @IsNumber()
  page?: number = 1;

  @ApiPropertyOptional({ default: 20 })
  @IsOptional()
  @IsNumber()
  limit?: number = 20;
}
