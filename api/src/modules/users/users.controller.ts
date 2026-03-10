import {
  Controller,
  Get,
  Patch,
  Post,
  Delete,
  Body,
  Param,
  Query,
  Req,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateProfileDto, CreateWishlistEntryDto } from './dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';

@ApiTags('Users')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get own profile' })
  async getProfile(@Req() req: any) {
    return this.usersService.getProfile(req.user.userId);
  }

  @Patch('me')
  @ApiOperation({ summary: 'Update own profile' })
  async updateProfile(@Req() req: any, @Body() dto: UpdateProfileDto) {
    return this.usersService.updateProfile(req.user.userId, dto);
  }

  @Post('me/profile-photo')
  @ApiOperation({ summary: 'Get presigned URL for profile photo upload' })
  async getProfilePhotoUrl(@Req() req: any, @Body('contentType') contentType: string) {
    return this.usersService.getProfilePhotoUploadUrl(req.user.userId, contentType);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get public profile' })
  async getPublicProfile(@Param('id') id: string) {
    return this.usersService.getPublicProfile(id);
  }

  @Get(':id/closet')
  @ApiOperation({ summary: 'Get user closet items' })
  async getUserCloset(
    @Param('id') id: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    return this.usersService.getUserCloset(id, { page: +page, limit: +limit });
  }

  @Get('me/wishlist')
  @ApiOperation({ summary: 'Get wishlist' })
  async getWishlist(@Req() req: any) {
    return this.usersService.getWishlist(req.user.userId);
  }

  @Post('me/wishlist')
  @ApiOperation({ summary: 'Add wishlist entry' })
  async addWishlistEntry(@Req() req: any, @Body() dto: CreateWishlistEntryDto) {
    return this.usersService.addWishlistEntry(req.user.userId, dto);
  }

  @Delete('me/wishlist/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Remove wishlist entry' })
  async removeWishlistEntry(@Param('id') id: string, @Req() req: any) {
    await this.usersService.removeWishlistEntry(id, req.user.userId);
  }
}
