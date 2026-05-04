import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as fs from 'fs';
import * as path from 'path';
import { randomUUID } from 'crypto';

@Injectable()
export class LocalStorageService {
  private readonly storagePath: string;
  private readonly baseUrl: string;
  private readonly uploadUrl: string;

  constructor(private readonly configService: ConfigService) {
    this.storagePath = this.configService.get<string>('LOCAL_STORAGE_PATH', './uploads');
    this.baseUrl = this.configService.get<string>('LOCAL_STORAGE_BASE_URL', 'http://localhost:3001/uploads');
    this.uploadUrl = this.configService.get<string>('LOCAL_STORAGE_UPLOAD_URL', 'http://localhost:3001/api/v1/items');

    if (!fs.existsSync(this.storagePath)) {
      fs.mkdirSync(this.storagePath, { recursive: true });
    }
  }

  async getPresignedUploadUrl(key: string, contentType: string): Promise<string> {
    return `http://192.168.1.50:3001/api/v1/items/upload-direct?key=${key}&contentType=${encodeURIComponent(contentType)}`;
  }

  async uploadFile(key: string, data: Buffer, contentType: string): Promise<string> {
    const ext = this.getExtension(contentType);
    const filename = `${key || randomUUID()}${ext}`;
    const filepath = path.join(this.storagePath, filename);

    const dir = path.dirname(filepath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    fs.writeFileSync(filepath, data);
    return filename;
  }

  async deleteObject(key: string): Promise<void> {
    const filepath = path.join(this.storagePath, path.basename(key));
    if (fs.existsSync(filepath)) {
      fs.unlinkSync(filepath);
    }
  }

  getPublicUrl(key: string): string {
    return `${this.baseUrl}/${key}`;
  }

  private getExtension(contentType: string): string {
    const mimeToExt: Record<string, string> = {
      'image/jpeg': '.jpg',
      'image/jpg': '.jpg',
      'image/png': '.png',
      'image/gif': '.gif',
      'image/webp': '.webp',
      'video/mp4': '.mp4',
      'video/quicktime': '.mov',
    };
    return mimeToExt[contentType] || '.bin';
  }
}