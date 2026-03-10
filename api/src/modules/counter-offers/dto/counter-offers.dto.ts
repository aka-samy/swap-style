import { IsString, IsOptional, IsNumber, IsArray, ValidateNested, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CounterOfferItemDto {
  @ApiProperty()
  @IsString()
  itemId: string;
}

export class ProposeCounterOfferDto {
  @ApiPropertyOptional({ type: [CounterOfferItemDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CounterOfferItemDto)
  items?: CounterOfferItemDto[];

  @ApiPropertyOptional({ default: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  monetaryAmount?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  message?: string;
}
