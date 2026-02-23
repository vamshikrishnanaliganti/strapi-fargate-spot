FROM node:18-alpine
RUN apk add --no-cache python3 make g++
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 1337
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=1337
CMD ["npm", "run", "start"]
