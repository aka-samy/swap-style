-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('USER', 'ADMIN');

-- AlterTable
ALTER TABLE "users"
ADD COLUMN "role" "UserRole" NOT NULL DEFAULT 'USER',
ADD COLUMN "suspended_until" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "items"
ADD COLUMN "shoe_size_eu" DOUBLE PRECISION;

-- CreateIndex
CREATE INDEX "items_category_shoe_size_eu_status_idx"
ON "items"("category", "shoe_size_eu", "status");
