FROM node:20-alpine AS builder

WORKDIR /app

# Copy API package files
COPY api/package.json api/package-lock.json ./
RUN npm ci

# Copy API source and Prisma schema
COPY api/ ./

# Generate Prisma client and build
# Dummy DATABASE_URL needed for prisma generate (no actual connection made)
ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"
RUN npx prisma generate
RUN npm run build
RUN ls -la dist/ && ls -la dist/main.js

# Production stage
FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/package.json /app/package-lock.json ./
RUN npm ci --omit=dev

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma
COPY --from=builder /app/node_modules/prisma ./node_modules/prisma
COPY --from=builder /app/prisma ./prisma

COPY entrypoint.sh ./
RUN sed -i 's/\r$//' entrypoint.sh && chmod +x entrypoint.sh

EXPOSE 3000

CMD ["./entrypoint.sh"]
