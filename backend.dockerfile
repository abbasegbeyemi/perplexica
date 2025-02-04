FROM node:22-alpine AS builder

WORKDIR /app

COPY package.json yarn.lock /app/
COPY tsconfig.json drizzle.config.ts /app/
COPY src /app/src

RUN yarn install --frozen-lockfile --network-timeout 600000 && yarn build

FROM node:22-alpine

ARG USER=node

WORKDIR /app

COPY --chown=$USER:$USER --from=builder /app/dist ./dist
COPY --chown=$USER:$USER --from=builder /app/node_modules ./node_modules
COPY --chown=$USER:$USER --from=builder /app/package.json ./package.json
COPY --chown=$USER:$USER --from=builder /app/tsconfig.json ./tsconfig.json
COPY --chown=$USER:$USER --from=builder /app/drizzle.config.ts ./drizzle.config.ts
COPY --chown=$USER:$USER --from=builder /app/src/db/schema.ts ./src/db/schema.ts

RUN mkdir /app/data && chown -R $USER:$USER /app/data && chmod -R 755 /app/data

USER $USER

CMD ["yarn", "start"]

