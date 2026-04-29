import {
  IsString,
  IsEnum,
  IsOptional,
  IsNumber,
  Min,
  Max,
  MinLength,
  MaxLength,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { ItemCategory, ItemSize, ItemCondition, ItemStatus } from '@prisma/client';

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

  @ApiPropertyOptional({ description: 'EU shoe size (required for shoes)', example: 42 })
  @IsOptional()
  @IsNumber()
  @Min(30)
  @Max(55)
  shoeSizeEu?: number;

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

export class UpdateItemDto extends PartialType(CreateItemDto) {
  @ApiPropertyOptional({ enum: ItemStatus })
  @IsOptional()
  @IsEnum(ItemStatus)
  status?: ItemStatus;
}

export class PaginationQueryDto {
  @ApiPropertyOptional({ default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  page?: number = 1;

  @ApiPropertyOptional({ default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  limit?: number = 20;
}
