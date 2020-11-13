import Config

IO.inspect("releases.exs")

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """


# backend_url = System.get_env("BACKEND_URL") || "localhost"

# config :chat_api,
#   ecto_repos: [ChatApi.Repo],
#   generators: [binary_id: true]

# config :chat_api, ChatApi.Repo,
#   ssl: false,
#   url: database_url,
#   pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

# config :chat_api, ChatApiWeb.Endpoint,
#   http: [
#     port: String.to_integer(System.get_env("PORT") || "4000"),
#     transport_options: [socket_opts: [:inet6]]
#   ],
#   url: [scheme: "https", host: {:system, backend_url}, port: 443],

database_url = System.get_env("DATABASE_URL") || "ecto://postgres:postgres@localhost/chat_api_dev"

# Configure your database
config :chat_api, ChatApi.Repo,
  url: database_url,
  show_sensitive_data_on_connection_error: false,
  pool_size: 10

config :chat_api, ChatApiWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [scheme: "https", host: {:system, "BACKEND_URL"}, port: 443],
  pubsub_server: ChatApi.PubSub,
  secret_key_base: secret_key_base,
  server: true
