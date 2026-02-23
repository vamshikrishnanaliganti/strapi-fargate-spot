FROM node:18-alpine AS builder

RUN apk add --no-cache python3 make g++

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

ENV NODE_ENV=production
ENV DATABASE_CLIENT=sqlite
ENV DATABASE_FILENAME=.tmp/data.db
ENV APP_KEYS=toBeModified1,toBeModified2
ENV API_TOKEN_SALT=toBeModified
ENV ADMIN_JWT_SECRET=toBeModified
ENV JWT_SECRET=toBeModified

RUN npm run build

FROM node:18-alpine

RUN apk add --no-cache python3 make g++

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY --from=builder /app/dist ./dist
COPY . .

EXPOSE 1337

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=1337

CMD ["npm", "run", "start"]