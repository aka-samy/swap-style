import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  Req,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { ItemsService } from './items.service';
import { CreateItemDto, UpdateItemDto, PaginationQueryDto } from './dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';

@ApiTags('Items')
@ApiBearerAuth()
@UseGuards(FirebaseAuthGuard)
@Controller('items')
export class ItemsController {
  constructor(private readonly itemsService: ItemsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new item listing' })
  @ApiResponse({ status: 201, description: 'Item created' })
  async create(@Req() req: any, @Body() dto: CreateItemDto) {
    return this.itemsService.create(req.user.userId, dto);
  }

  @Get('me')
  @ApiOperation({ summary: 'List authenticated user closet items' })
  async findMyItems(@Req() req: any, @Query() query: PaginationQueryDto) {
    return this.itemsService.findByOwner(req.user.userId, {
      page: query.page ?? 1,
      limit: query.limit ?? 20,
    });
  }

  @Get(':id/stats')
  @ApiOperation({ summary: 'Get item engagement stats (likes and matches)' })
  async getItemStats(@Param('id') id: string) {
    return this.itemsService.getItemStats(id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a single item' })
  @ApiResponse({ status: 404, description: 'Item not found' })
  async findOne(@Param('id') id: string) {
    return this.itemsService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update an item' })
  @ApiResponse({ status: 403, description: 'Not the owner' })
  async update(@Param('id') id: string, @Req() req: any, @Body() dto: UpdateItemDto) {
    return this.itemsService.update(id, req.user.userId, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Remove an item from closet' })
  async remove(@Param('id') id: string, @Req() req: any) {
    await this.itemsService.remove(id, req.user.userId);
  }

  @Post(':id/verify')
  @ApiOperation({ summary: 'Submit verification checklist for an item' })
  async verify(
    @Param('id') id: string,
    @Req() req: any,
    @Body() body: {
      washed: boolean;
      noStains: boolean;
      noTears: boolean;
      noDefects: boolean;
      photosAccurate: boolean;
    },
  ) {
    return this.itemsService.verifyItem(id, req.user.userId, body);
  }

  @Post(':id/photos/upload-url')
  @ApiOperation({ summary: 'Get presigned upload URL for an item photo' })
  async getUploadUrl(
    @Param('id') id: string,
    @Req() req: any,
    @Body() body: { contentType: string },
  ) {
    return this.itemsService.getPresignedUploadUrl(id, req.user.userId, body.contentType);
  }

  @Delete(':id/photos/:photoId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Remove a photo from an item' })
  async removePhoto(
    @Param('id') id: string,
    @Param('photoId') photoId: string,
    @Req() req: any,
  ) {
    await this.itemsService.removePhoto(id, photoId, req.user.userId);
  }
}
