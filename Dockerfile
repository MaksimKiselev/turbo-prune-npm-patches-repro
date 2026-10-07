# A trimmed version of the multi-stage build in the Turborepo Docker guide, with npm 12.
# docker build --build-arg APP=web .

FROM node:24-alpine AS base
RUN npm install -g npm@12.2.0 turbo@2.11.7

FROM base AS prune
ARG APP
WORKDIR /app
COPY . .
RUN turbo prune "$APP" --docker

FROM base AS installer
ARG APP
WORKDIR /app
COPY --from=prune /app/out/json/ .
RUN npm ci
COPY --from=prune /app/out/full/ .
RUN npm start --workspace "$APP"
