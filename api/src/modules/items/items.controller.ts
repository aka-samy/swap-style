import * as fs from 'fs';
import * as path from 'path';
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
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { ItemsService } from './items.service';
import { CreateItemDto, UpdateItemDto, PaginationQueryDto } from './dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { FileInterceptor } from '@nestjs/platform-express';
import { LocalStorageService } from '../../common/storage/local-storage.service';

@ApiTags('Items')
@Controller('items')
@UseGuards(FirebaseAuthGuard)
@ApiBearerAuth()
export class ItemsController {
  constructor(
    private readonly itemsService: ItemsService,
    private readonly storageService: LocalStorageService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create a new item listing' })
  @ApiResponse({ status: 201, description: 'Item created' })
  async create(@Req() req: any, @Body() dto: CreateItemDto) {
    return this.itemsService.create(req.user.userId, dto);
  }

  @Get('me')
  @ApiOperation({ summary: 'List authenticated user closet items' })
  async findMyItems(@Req() req: any, @Query() query: PaginationQueryDto) {
    console.log('findMyItems called, userId:', req.user?.userId);
    return this.itemsService.findByOwner(req.user.userId, {
      page: query.page ?? 1,
      limit: query.limit ?? 20,
    });
  }

  @Get('liked')
  @ApiOperation({ summary: 'List authenticated user liked items' })
  async findLikedItems(@Req() req: any, @Query() query: PaginationQueryDto) {
    return this.itemsService.findLikedByOwner(req.user.userId, {
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
    const key = `item-${id}-${Date.now()}.jpg`;
    return { 
      uploadUrl: `http://192.168.1.50:3001/api/v1/items/${id}/photos/upload-simple`, 
      publicUrl: `http://192.168.1.50:3001/uploads/${key}`, 
      key 
    };
  }

  @Post(':id/photos/upload-simple')
  @UseGuards(FirebaseAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Upload photo via JSON body (base64)' })
  async uploadPhotoSimple(
    @Param('id') id: string,
    @Req() req: any,
    @Body() body: { imageData: string; contentType: string },
  ) {
    console.log('uploadPhotoSimple called, id:', id);
    try {
      const buffer = Buffer.from(body.imageData, 'base64');
      const filename = `item-${id}-${Date.now()}.jpg`;
      const filepath = path.join(process.cwd(), 'uploads', filename);
      fs.writeFileSync(filepath, buffer);
      const publicUrl = `http://192.168.1.50:3001/uploads/${filename}`;
      return this.itemsService.addPhoto(id, req.user.userId, publicUrl, filename);
    } catch (e) {
      console.error('uploadPhotoSimple error:', e);
      throw e;
    }
  }

  @Post(':id/photos/upload')
  @UseInterceptors(FileInterceptor('file'))
  @ApiBearerAuth()
  @UseGuards(FirebaseAuthGuard)
  @ApiOperation({ summary: 'Upload a photo directly to local storage' })
  async uploadPhoto(
    @Param('id') id: string,
    @Req() req: any,
    @UploadedFile() file: any,
  ) {
    console.log('uploadPhoto called, file:', file?.originalname);
    try {
      const key = await this.storageService.uploadFile('', file.buffer, file.mimetype);
      const publicUrl = this.storageService.getPublicUrl(key);
      console.log('uploadPhoto success, key:', key, 'url:', publicUrl);
      return this.itemsService.addPhoto(id, req.user.userId, publicUrl, key);
    } catch (e) {
      console.error('uploadPhoto error:', e);
      throw e;
    }
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