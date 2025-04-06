# Stage 1: Install dev dependencies
FROM oven/bun:1.0.30-alpine AS development-dependencies-env
COPY . /app
WORKDIR /app
RUN bun install

# Stage 2: Install only production dependencies
FROM oven/bun:1.0.30-alpine AS production-dependencies-env
COPY ./bun.lockb ./package.json /app/
WORKDIR /app
RUN bun install --production

# Stage 3: Build the app
FROM oven/bun:1.0.30-alpine AS build-env
COPY . /app
COPY --from=development-dependencies-env /app/bun.lockb /app/bun.lockb
COPY --from=development-dependencies-env /app/node_modules /app/node_modules
WORKDIR /app
RUN bun run build

# Final stage: Run the app
FROM oven/bun:1.0.30-alpine
COPY ./bun.lockb ./package.json /app/
COPY --from=production-dependencies-env /app/node_modules /app/node_modules
COPY --from=build-env /app/build /app/build
WORKDIR /app
CMD ["bun", "run", "start"]