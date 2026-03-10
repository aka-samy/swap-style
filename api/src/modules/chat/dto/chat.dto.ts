import { IsString, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SendMessageDto {
  @ApiProperty({ maxLength: 2000 })
  @IsString()
  @MaxLength(2000)
  text: string;
}

export class MessageCursorQueryDto {
  @ApiPropertyOptional()
  cursor?: string;

  @ApiPropertyOptional({ default: 20 })
  limit?: number = 20;
}
