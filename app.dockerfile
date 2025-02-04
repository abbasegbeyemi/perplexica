FROM node:22-alpine AS builder

WORKDIR /app

# Copy package.json and yarn.lock
COPY package.json yarn.lock ./
COPY ui /app

# Install dependencies and build the application
RUN yarn install --frozen-lockfile && yarn build

FROM node:22-alpine 
ENV NEXT_PUBLIC_WS_URL=ws://localhost:3001
ENV NEXT_PUBLIC_API_URL=http://localhost:3001/api

WORKDIR /app

COPY --chown=node:node --from=builder /app/.next ./.next
COPY --chown=node:node --from=builder /app/node_modules ./node_modules
COPY --chown=node:node --from=builder /app/package.json ./package.json
COPY --chown=node:node --from=builder /app/public ./public

USER node

CMD ["yarn", "start"]
