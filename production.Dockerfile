# FROM elixir:1.10.4 as builder

# # build step
# ARG MIX_ENV=prod
# ARG NODE_ENV=production
# ARG APP_VER=0.0.1
# ENV APP_VERSION=$APP_VER

# RUN mkdir /app
# WORKDIR /app

# RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
#     apt-get install -y nodejs fswatch

# # Client side
# COPY assets/package.json assets/package-lock.json ./assets/
# RUN npm install --prefix=assets

# # fix because of https://github.com/facebook/create-react-app/issues/8413
# ENV GENERATE_SOURCEMAP=false

# COPY priv priv
# COPY assets assets
# RUN npm run build --prefix=assets

# COPY mix.exs mix.lock ./
# COPY config config

# RUN mix local.hex --force && \
#     mix local.rebar --force && \
#     mix deps.get --only prod

# COPY lib lib
# RUN mix deps.compile
# RUN mix phx.digest

# WORKDIR /app
# RUN mix release 
# ENV LANG=C.UTF-8

# COPY docker-entrypoint.sh /entrypoint.sh
# RUN chmod a+x /entrypoint.sh

# # RUN adduser -home /app -u 1000 --shell /bin/sh --disabled-password  --gecos "" papercupsuser
# RUN chown -R papercupsuser:nogroup /app

# WORKDIR /app
# ENTRYPOINT ["/entrypoint.sh"]
# CMD ["run"]


FROM elixir:1.10.4-alpine as builder

# build step
ARG MIX_ENV=prod
ARG NODE_ENV=production
ARG APP_VER=0.0.1
ENV APP_VERSION=$APP_VER

RUN mkdir /app
WORKDIR /app

RUN apk add --no-cache git nodejs yarn python npm ca-certificates wget gnupg make erlang gcc libc-dev && \
    npm install npm@latest -g 

# Client side
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm install --prefix=assets

# fix because of https://github.com/facebook/create-react-app/issues/8413
ENV GENERATE_SOURCEMAP=false

COPY priv priv
COPY assets assets
RUN npm run build --prefix=assets

COPY mix.exs mix.lock ./
COPY config config

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod

COPY lib lib
RUN mix deps.compile
RUN mix phx.digest

WORKDIR /app
COPY rel rel
RUN mix release papercups

FROM alpine:3.9 AS app
RUN apk add --no-cache openssl ncurses-libs
ENV LANG=C.UTF-8
EXPOSE 4000

WORKDIR /app

ENV HOME=/app

RUN adduser -h /app -u 1000 -s /bin/sh -D papercupsuser

COPY --from=builder --chown=papercupsuser:papercupsuser /app/_build/prod/rel/papercups /app
RUN chown -R papercupsuser:papercupsuser /app

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

USER papercupsuser

WORKDIR /app
ENTRYPOINT ["/entrypoint.sh"]
CMD ["run"]


# #### Builder
# FROM elixir:1.10.4-alpine as buildcontainer

# # preparation
# ARG APP_VER=0.0.1
# ENV MIX_ENV=prod
# ENV NODE_ENV=production
# ENV APP_VERSION=$APP_VER

# RUN mkdir /app
# WORKDIR /app

# # install build dependencies
# RUN apk add --no-cache git nodejs yarn python npm ca-certificates wget gnupg make erlang gcc libc-dev && \
#     npm install npm@latest -g 

# COPY mix.exs ./
# COPY mix.lock ./
# RUN mix local.hex --force && \
#         mix local.rebar --force && \
#         mix deps.get --only prod && \
#         mix deps.compile

# COPY assets/package.json assets/package-lock.json ./assets/

# RUN npm audit fix --prefix ./assets && \
#     npm install --prefix ./assets

# COPY assets ./assets
# COPY config ./config
# COPY priv ./priv
# COPY lib ./lib

# RUN npm run deploy --prefix ./assets && \
#     mix phx.digest priv/static

# WORKDIR /app
# COPY rel rel
# RUN mix release papercups 

# # Main Docker Image
# FROM elixir:1.10.4-alpine
# ENV LANG=C.UTF-8

# RUN apk add --no-cache openssl ncurses

# COPY docker-entrypoint.sh /entrypoint.sh

# RUN chmod a+x /entrypoint.sh  && \
#     adduser -h /app -u 1000 -s /bin/sh -D papercups

# COPY --from=buildcontainer /app/_build/prod/rel/papercups /app
# RUN chown -R papercups:papercups /app

# USER papercups
# WORKDIR /app
# ENTRYPOINT ["/entrypoint.sh"]
# CMD ["run"]