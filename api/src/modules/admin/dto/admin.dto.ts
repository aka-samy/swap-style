import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import {
  ItemCategory,
  ItemStatus,
  MatchStatus,
  ReportStatus,
  UserRole,
} from '@prisma/client';

export class AdminPaginationDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}

export class AdminUsersQueryDto extends AdminPaginationDto {
  @IsOptional()
  @IsString()
  search?: string;
}

export class SuspendUserDto {
  @IsOptional()
  @IsBoolean()
  clear?: boolean;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(365)
  days?: number;

  @IsOptional()
  @IsISO8601()
  suspendedUntil?: string;
}

export class UpdateUserRoleDto {
  @IsEnum(UserRole)
  role: UserRole;
}

export class AdminReportsQueryDto extends AdminPaginationDto {
  @IsOptional()
  @IsEnum(ReportStatus)
  status?: ReportStatus;
}

export class ResolveReportDto {
  @IsEnum(ReportStatus)
  status: ReportStatus;
}

export class AdminItemsQueryDto extends AdminPaginationDto {
  @IsOptional()
  @IsEnum(ItemStatus)
  status?: ItemStatus;

  @IsOptional()
  @IsEnum(ItemCategory)
  category?: ItemCategory;
}

export class ModerateItemDto {
  @IsEnum(ItemStatus)
  status: ItemStatus;
}

export class AdminMatchesQueryDto extends AdminPaginationDto {
  @IsOptional()
  @IsEnum(MatchStatus)
  status?: MatchStatus;
}
