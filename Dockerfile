FROM elixir:slim

RUN apt-get update && \
    apt-get install -y ca-certificates openssl git

WORKDIR /app

COPY mix.exs mix.lock ./

RUN mix deps.get

COPY . .

RUN mix compile

CMD ["iex", "-S", "mix"]