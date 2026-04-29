import { IsString, IsOptional, IsNumber, Min, Max } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class OpenChatMatchDto {
  @ApiPropertyOptional({
    description: 'Item ID to start a chat about',
    example: '31000000-0000-4000-8000-000000000001',
  })
  @IsString()
  itemId: string;

  @ApiPropertyOptional({
    description: 'Optional first message. If omitted, a default interest message is sent.',
  })
  @IsOptional()
  @IsString()
  initialMessage?: string;
}

export class MatchQueryDto {
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

  @ApiPropertyOptional({ description: 'Comma-separated status filter' })
  @IsOptional()
  @IsString()
  status?: string;
}
