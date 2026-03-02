FROM node:22-alpine AS builder
RUN npm install -g pnpm
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/angular-app/package.json ./apps/angular-app/
RUN pnpm install --frozen-lockfile --filter angular-app
COPY apps/angular-app ./apps/angular-app
WORKDIR /app/apps/angular-app
RUN pnpm run build

FROM nginx:alpine
COPY --from=builder /app/apps/angular-app/dist/angular-app/browser /usr/share/nginx/html
EXPOSE 80
