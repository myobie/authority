FROM elixir:1.5.2

MAINTAINER Nathan Herald

CMD /bin/bash

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install nodejs -y

ENV MIX_ENV=prod

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

WORKDIR /app
RUN mkdir config

COPY mix.exs mix.lock /app/
COPY config/config.exs config/prod.exs config/prod.secret.exs config/dev.secret.private config/dev.secret.public /app/config/

# Must get deps before npm install becuase some javascript is inside some of
# the elixir packages
RUN mix do deps.get --only prod, deps.compile

WORKDIR /app/assets

COPY assets/package.json assets/package-lock.json /app/assets/

RUN npm install

COPY assets /app/assets/
RUN npm run deploy

WORKDIR /app

RUN mix phx.digest

COPY priv /app/priv/
COPY lib /app/lib/
COPY VERSION /app/VERSION

RUN mix compile

COPY rel /app/rel/

RUN mix release --env=prod
