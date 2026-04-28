FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .


FROM gcr.io/distroless/nodejs20-debian12

WORKDIR /app

COPY --from=build /app .

EXPOSE 5000

CMD ["server.js"]